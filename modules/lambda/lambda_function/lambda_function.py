import zipfile
import xml.etree.ElementTree as ET
from io import BytesIO
from datetime import datetime
import unicodedata
import json
import boto3
import os
import urllib.parse
import re  


SOURCE_BUCKET = os.environ["RAW_BUCKET_NAME"]
DESTINATION_BUCKET = os.environ["PROCESSED_BUCKET_NAME"]


s3_client = boto3.client("s3") 


def get_s3_object(event):
    try:
        source_key = urllib.parse.unquote_plus(
            event["Records"][0]["s3"]["object"]["key"]
        )

        # MODIFICADO: validar que únicamente se procesen DOCX
        if not source_key.lower().endswith(".docx"):
            raise ValueError(f"Archivo no soportado: {source_key}")

        response = s3_client.get_object(
            Bucket=SOURCE_BUCKET,
            Key=source_key
        )

        return response, source_key

    except Exception as e:
        print(f"Error obteniendo archivo S3: {str(e)}")
        raise


def upload_policy_s3(txt_buffer, json_buffer, key):
    s3_client.put_object(
        Bucket=DESTINATION_BUCKET,
        Key=f"{key}.txt",
        Body=txt_buffer.getvalue(),
        ContentType="text/plain; charset=utf-8"
    )

    s3_client.put_object(
        Bucket=DESTINATION_BUCKET,
        Key=f"{key}.metadata.json",
        Body=json_buffer.getvalue(),
        ContentType="application/json"
    )


def normalizar(texto):
    texto = texto.lower().strip()

    texto = ''.join(
        c for c in unicodedata.normalize("NFD", texto)
        if unicodedata.category(c) != "Mn"
    )

    return " ".join(texto.split())


def extract_docx_text(docx_bytes):
    try:
        with zipfile.ZipFile(BytesIO(docx_bytes)) as docx_zip:
            xml_content = docx_zip.read("word/document.xml")

        root = ET.fromstring(xml_content)

        namespace = {
            "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        }

        paragraphs = []

        for paragraph in root.findall(".//w:p", namespace):
            texts = []

            for text in paragraph.findall(".//w:t", namespace):
                if text.text:
                    texts.append(text.text)

            paragraph_text = "".join(texts).strip()

            if paragraph_text:
                paragraphs.append(paragraph_text)

        return paragraphs

    except Exception as e:
        raise RuntimeError(f"Error al procesar el DOCX: {str(e)}")


def extraer_metadata(paragraphs):
    metadata = {
        "fecha_extraccion": datetime.now().isoformat(),
        "politica": "",
        "codigo": "",
        "version": "",
        "clasificacion": "",
        "fecha_de_emision": "",
        "dominio": "",
        "area_responsable": "",
        "responsable": "",
        "estado": ""
    }

    palabras_clave = {
        "codigo": ["codigo", "código"],
        "version": ["version", "versión"],
        "clasificacion": ["clasificacion", "clasificación"],
        "fecha_de_emision": ["fecha de emision", "fecha de emisión"],
        "dominio": ["dominio"],
        "area_responsable": ["area responsable", "área responsable"],
        "responsable": ["responsable"],
        "estado": ["estado"]
    }

    for i, linea in enumerate(paragraphs):

        linea_normalizada = normalizar(linea)

        # MODIFICADO: se detiene al iniciar el contenido del documento (1. Objetivo, 2. Alcance, etc.)
        if re.match(r"^\d+\.\s", linea_normalizada):
            break

        # MODIFICADO: detección más flexible del nombre de la política
        if "politica" in linea_normalizada and metadata["politica"] == "":
            metadata["politica"] = linea

        for campo, variantes in palabras_clave.items():

            if any(linea_normalizada == normalizar(v) for v in variantes):

                # MODIFICADO: evita sobrescribir un valor ya encontrado
                if i + 1 < len(paragraphs) and metadata[campo] == "":
                    metadata[campo] = paragraphs[i + 1].strip()

                break

    return metadata


def create_archives(content, metadata):
    txt_buffer = BytesIO()

    txt_buffer.write(content.encode("utf-8"))
    txt_buffer.seek(0)

    json_buffer = BytesIO()

    json_buffer.write(
        json.dumps(metadata, ensure_ascii=False, indent=4).encode("utf-8")
    )

    json_buffer.seek(0)

    return txt_buffer, json_buffer


def lambda_handler(event, context):
    try:  # MODIFICADO: manejo general de errores

        response, key = get_s3_object(event)

        file_bytes = response["Body"].read()

        paragraphs = extract_docx_text(file_bytes)

        contenido = "\n\n".join(paragraphs)

        metadata = extraer_metadata(paragraphs)

        txt_buffer, json_buffer = create_archives(
            contenido,
            metadata
        )

        file_name = key.rsplit(".", 1)[0]

        upload_policy_s3(
            txt_buffer,
            json_buffer,
            file_name
        )

        return {  # MODIFICADO: respuesta explícita de éxito
            "statusCode": 200,
            "body": f"Documento {key} procesado correctamente"
        }

    except Exception as e:
        print(f"Error en lambda_handler: {str(e)}")
        raise
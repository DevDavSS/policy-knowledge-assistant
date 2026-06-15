resource "aws_bedrockagent_agent" "internal_policy_assistant" {
    agent_name = "ia-test-internal-policy-assistant"

    agent_resource_role_arn = var.bedrock_agentcore_role_arn
    foundation_model = "amazon.nova-pro-v1:0"

    instruction = <<EOF
    Eres un asistente de políticas internas de la emmpresa ION Financiera.
    
    Tus responsabilidades son las siguientes:
    - Responder preguntas sobre las políticas internas de la empresa.
    - Usa la base de conocimiento cuando se requiera documentación de la empresa.
    - Provee de respuestas precisas y concisas.
    - Si la información no está disponible, responde que no posees esa información en lugar de inventar respuestas.
    EOF
    
    idle_session_ttl_in_seconds = 1800
}

resource "aws_bedrockagent_agent_knowledge_base_association" "kb_association" {
    agent_id = aws_bedrockagent_agent.internal_policy_assistant.id

    description = "Base de conocimiento de politicas internas de la empresa"

    knowledge_base_id = var.knowledge_base_id

    knowledge_base_state = "ENABLED"
}

/*Temporary Alias*/
resource "aws_bedrockagent_agent_alias" "test_alias" {

  agent_id = aws_bedrockagent_agent.internal_policy_assistant.id

  agent_alias_name = "test"
}
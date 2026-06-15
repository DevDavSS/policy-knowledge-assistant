output "agent_id" {
  value = aws_bedrockagent_agent.internal_policy_assistant.id
}

output "agent_alias_id"{
    value = aws_bedrockagent_agent_alias.test_alias.id
}
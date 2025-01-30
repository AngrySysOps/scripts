#This script is a showcase how to interate AI model in Python
#Subscribe to my Youtube channel @AngryAdmin
# x: @AngrySysOps

import ollama

# Initialize the Ollama client
client = ollama.Client()

# Prompt the user for input
user_query = input("Enter your query: ")

# Define the model
model = "llama2"  # Replace with your model name

# Send the user query to the model
response = client.generate(model=model, prompt=user_query)

# Print the response from the model
print("Response from Ollama:")
print(response.response)

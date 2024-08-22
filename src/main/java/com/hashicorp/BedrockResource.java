package com.hashicorp;


import dev.langchain4j.model.bedrock.BedrockAnthropicMessageChatModel;
import dev.langchain4j.model.chat.ChatLanguageModel;
import io.quarkus.runtime.Startup;
import io.quarkus.logging.Log;
import jakarta.inject.Singleton;
import software.amazon.awssdk.regions.Region;

@Singleton
public class BedrockResource  implements ChatBot {

    private ChatLanguageModel model;
    public String modelName = BedrockAnthropicMessageChatModel.Types.AnthropicClaude3SonnetV1.getValue();
    public Region region = Region.US_WEST_2;
    public float temperature = 0.50f;
    public int maxTokens = 300;
    public int retries = 1;

    @Startup
    public void setup() {
        // For authentication, set the following environment variables:
        // AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
        // More info on creating the API keys:
        // https://docs.aws.amazon.com/bedrock/latest/userguide/api-setup.html

        try {
            model = BedrockAnthropicMessageChatModel
                    .builder()
                    .region(region)
                    .model(modelName)
                    .temperature(temperature)
                    .maxTokens(maxTokens)
                    .maxRetries(retries)
                    .build();

            Log.info("Bedrock model created");
            String joke = model.generate("Tell me a joke");
            Log.info("Today's startup joke\n:" + joke);
        }
        catch (Exception e) {
            Log.error("Could not access AWS:"+  e.getLocalizedMessage());
            Log.error("AWS_ACCESS_KEY_ID:" + System.getenv("AWS_ACCESS_KEY_ID"));
            Log.error("AWS_SECRET_ACCESS_KEY:" + System.getenv("AWS_SECRET_ACCESS_KEY"));
        }
    }

    @Override
    public String chat(String question) {

        Log.debug("Question received: " + question);
        String response = model.generate(question);
        Log.debug("Response: " + response);

        return response;
    }
}


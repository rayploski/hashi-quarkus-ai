package com.hashicorp;

import io.quarkus.websockets.next.OnOpen;
import io.quarkus.websockets.next.OnTextMessage;
import io.quarkus.websockets.next.WebSocket;
import jakarta.inject.Inject;

@WebSocket(path = "/chat")
public class ChatWebSocket {
    @Inject ChatBot bot;

    @OnOpen
    String welcome() {return "Welcome, how can I help you today?";}

    @OnTextMessage
    String onMessage(String message) {
        return bot.chat(message);
    }

}

package com.hashicorp;

import jakarta.enterprise.context.SessionScoped;

@SessionScoped
public interface ChatBot {

    String chat(String question);

}
package com.astraval.kumarbrooms.modules.auth.service;

import com.astraval.kumarbrooms.modules.auth.request.LoginRequest;
import com.astraval.kumarbrooms.modules.auth.request.RegisterRequest;
import com.astraval.kumarbrooms.modules.auth.response.AuthResult;
import com.astraval.kumarbrooms.modules.auth.response.AuthTokenPair;

public interface AuthService {

    AuthResult register(RegisterRequest request);

    AuthResult login(LoginRequest request);

    AuthTokenPair refreshTokens(String refreshToken);
}

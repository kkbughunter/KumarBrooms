package com.astraval.kumarbrooms.modules.auth.mapper;

import com.astraval.kumarbrooms.modules.auth.response.AuthResponse;
import com.astraval.kumarbrooms.modules.auth.response.AuthResult;
import org.springframework.stereotype.Component;

@Component
public class AuthMapper {

    public AuthResponse toAuthResponse(AuthResult result) {
        return AuthResponse.builder()
                .userId(result.getUserId())
                .orgId(result.getOrgId())
                .orgCode(result.getOrgCode())
                .email(result.getEmail())
                .fullName(result.getFullName())
                .gender(result.getGender())
                .phone(result.getPhone())
                .roles(result.getRoles())
                .build();
    }
}

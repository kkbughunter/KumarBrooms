package com.astraval.kumarbrooms.modules.user.service;

import com.astraval.kumarbrooms.modules.user.request.UpdateProfileRequest;
import com.astraval.kumarbrooms.modules.user.response.UserProfileResponse;

import java.util.UUID;

public interface UserService {

    UserProfileResponse getProfile(UUID userId);

    UserProfileResponse updateProfile(UUID userId, UpdateProfileRequest request);
}

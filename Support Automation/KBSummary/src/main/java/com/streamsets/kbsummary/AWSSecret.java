package com.streamsets.kbsummary;

import com.amazonaws.services.secretsmanager.AWSSecretsManager;
import com.amazonaws.services.secretsmanager.AWSSecretsManagerClientBuilder;
import com.amazonaws.services.secretsmanager.model.GetSecretValueRequest;
import com.amazonaws.services.secretsmanager.model.GetSecretValueResult;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

class AWSSecret {
  Logger LOG = LoggerFactory.getLogger(AWSSecret.class);

  AWSSecret() {

  }

  /**
   * Returns a Map of the contents of the specified AWS Secret Manager Secret.
   *
   * @param secretName
   * @param AWSRegion
   * @return - Map of String keys and values.   Returns empty Map on failure also may return an empty Map if its
   * binary secret.
   */
  Map<String, String> getSecret(String secretName, String AWSRegion) {

    // Create a Secrets Manager client
    AWSSecretsManager client = AWSSecretsManagerClientBuilder.standard().withRegion(AWSRegion).build();

    String secret = "";
    String decodedBinarySecret = "";
    GetSecretValueRequest getSecretValueRequest = new GetSecretValueRequest().withSecretId(secretName);
    GetSecretValueResult getSecretValueResult = null;

    getSecretValueResult = client.getSecretValue(getSecretValueRequest);

    // only support String contents.  not binary.
    if (getSecretValueResult.getSecretString() != null) {
      return new Gson().fromJson(getSecretValueResult.getSecretString(), new TypeToken<HashMap<String, Object>>() {
      }.getType());

    } else {
      return new HashMap<String, String>();
      //      decodedBinarySecret = new String(Base64.getDecoder().decode(getSecretValueResult.getSecretBinary())
      //      .array());

    }
  }
}

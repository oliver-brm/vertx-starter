/*
 * Copyright 2019 Red Hat, Inc.
 *
 * Red Hat licenses this file to you under the Apache License, version 2.0
 * (the "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

package io.vertx.starter.service.util;

import io.vertx.core.json.Json;
import io.vertx.core.json.JsonArray;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

/**
 * @author Thomas Segismont
 */
public class MetadataUtil {

  public static JsonArray loadDependencies() {
    try (InputStream is = MetadataUtil.class.getClassLoader().getResourceAsStream("dependencies.json")) {
      return new JsonArray(Json.mapper.readValue(is, List.class));
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  private MetadataUtil() {
  }
}

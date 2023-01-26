/*
 * Copyright 2022 Red Hat, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package images

import (
	"os"

	"k8s.io/klog/v2"
)

func GetPauseImage() string {
	pullSpec := getPauseImage()
	klog.Infof("using pause image: %q", pullSpec)
	return pullSpec
}

func getPauseImage() string {
	if pullSpec, ok := os.LookupEnv("E2E_NROP_URL_PAUSE_IMAGE"); ok {
		return pullSpec
	}
	// backward compatibility
	if pullSpec, ok := os.LookupEnv("E2E_PAUSE_IMAGE_URL"); ok {
		return pullSpec
	}
	return PauseImage
}

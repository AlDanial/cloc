#!/usr/bin/env nextflow
// https://github.com/nextflow-io/nextflow/raw/refs/heads/master/tests/cli-args.nf
/*
 * Copyright 2013-2024, Seqera Labs
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
 
println "alpha: ${params.alpha}"
println "beta : ${params.beta}"
println "delta: ${params.delta}"
println "gamma: ${params.gamma}"
println "omega: ${params.omega}"
println "args : ${args.join('_')}"

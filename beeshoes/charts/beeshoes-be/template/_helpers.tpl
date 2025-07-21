{{/*
Expand the name of the chart.
*/}}
{{- define "beeshoes-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "beeshoes-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "beeshoes-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "beeshoes-app.labels" -}}
helm.sh/chart: {{ include "beeshoes-app.chart" . }}
{{ include "beeshoes-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: beeshoes-ecommerce
{{- end }}

{{/*
Selector labels
*/}}
{{- define "beeshoes-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "beeshoes-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
==============================================
FRONTEND TIER HELPERS
==============================================
*/}}

{{/*
Frontend labels (matching manifest)
*/}}
{{- define "beeshoes-app.frontend.labels" -}}
{{ include "beeshoes-app.labels" . }}
app: beeshoes-fe
tier: frontend
{{- end }}

{{/*
Frontend selector labels (matching manifest)
*/}}
{{- define "beeshoes-app.frontend.selectorLabels" -}}
app: beeshoes-fe
{{- end }}

{{/*
Frontend image
*/}}
{{- define "beeshoes-app.frontend.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.frontend.image.repository -}}
{{- $tag := .Values.frontend.image.tag | default .Chart.AppVersion -}}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Frontend service name (from manifest)
*/}}
{{- define "beeshoes-app.frontend.serviceName" -}}
{{- .Values.frontend.service.name | default "beeshoes-fe-service" }}
{{- end }}

{{/*
==============================================
BACKEND TIER HELPERS
==============================================
*/}}

{{/*
Backend labels (matching manifest)
*/}}
{{- define "beeshoes-app.backend.labels" -}}
{{ include "beeshoes-app.labels" . }}
app: beeshoes-be
tier: backend
{{- end }}

{{/*
Backend selector labels (matching manifest)
*/}}
{{- define "beeshoes-app.backend.selectorLabels" -}}
app: beeshoes-be
{{- end }}

{{/*
Backend image
*/}}
{{- define "beeshoes-app.backend.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.backend.image.repository -}}
{{- $tag := .Values.backend.image.tag | default .Chart.AppVersion -}}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Backend service name (from manifest)
*/}}
{{- define "beeshoes-app.backend.serviceName" -}}
{{- .Values.backend.service.name | default "beeshoes-be-service" }}
{{- end }}

{{/*
Backend secret name (from manifest)
*/}}
{{- define "beeshoes-app.backend.secretName" -}}
beeshoes-be-secret
{{- end }}

{{/*
Backend configmap name (from manifest)
*/}}
{{- define "beeshoes-app.backend.configMapName" -}}
beeshoes-be-application-properties-configmap
{{- end }}

{{/*
==============================================
DATABASE TIER HELPERS
==============================================
*/}}

{{/*
Database labels (matching manifest)
*/}}
{{- define "beeshoes-app.database.labels" -}}
{{ include "beeshoes-app.labels" . }}
app: beeshoes-db
tier: database
{{- end }}

{{/*
Database selector labels (matching manifest)
*/}}
{{- define "beeshoes-app.database.selectorLabels" -}}
app: beeshoes-db
{{- end }}

{{/*
Database image
*/}}
{{- define "beeshoes-app.database.image" -}}
{{- $repository := .Values.mariadb.image.repository -}}
{{- $tag := .Values.mariadb.image.tag -}}
{{- printf "%s:%s" $repository $tag }}
{{- end }}

{{/*
Database service name (from manifest)
*/}}
{{- define "beeshoes-app.database.serviceName" -}}
{{- .Values.mariadb.service.name | default "beeshoes-db-service" }}
{{- end }}

{{/*
Database secret name (from manifest)
*/}}
{{- define "beeshoes-app.database.secretName" -}}
beeshoes-db-secret
{{- end }}

{{/*
Database PVC name (from manifest)
*/}}
{{- define "beeshoes-app.database.pvcName" -}}
beeshoes-db-pvc
{{- end }}

{{/*
==============================================
DATABASE INIT JOB HELPERS
==============================================
*/}}

{{/*
Database init job name
*/}}
{{- define "beeshoes-app.database.initJobName" -}}
{{- printf "%s-db-init" (include "beeshoes-app.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Database init image
*/}}
{{- define "beeshoes-app.database.initImage" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.mariadb.dbInit.image.repository | default "beeshoes-db-init" -}}
{{- $tag := .Values.mariadb.dbInit.image.tag | default "v1" -}}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Database init resources
*/}}
{{- define "beeshoes-app.database.initResources" -}}
{{- with .Values.mariadb.dbInit.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
==============================================
UTILITY HELPERS
==============================================
*/}}

{{/*
Image pull secrets
*/}}
{{- define "beeshoes-app.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ .name }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Namespace
*/}}
{{- define "beeshoes-app.namespace" -}}
{{- .Values.global.namespace | default .Release.Namespace }}
{{- end }}

{{/*
==============================================
RESOURCE HELPERS
==============================================
*/}}

{{/*
Frontend resources
*/}}
{{- define "beeshoes-app.frontend.resources" -}}
{{- with .Values.frontend.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Backend resources
*/}}
{{- define "beeshoes-app.backend.resources" -}}
{{- with .Values.backend.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Database resources
*/}}
{{- define "beeshoes-app.database.resources" -}}
{{- with .Values.mariadb.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
==============================================
PROBE HELPERS
==============================================
*/}}

{{/*
Frontend liveness probe
*/}}
{{- define "beeshoes-app.frontend.livenessProbe" -}}
{{- with .Values.frontend.livenessProbe }}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Frontend readiness probe
*/}}
{{- define "beeshoes-app.frontend.readinessProbe" -}}
{{- with .Values.frontend.readinessProbe }}
readinessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Backend liveness probe
*/}}
{{- define "beeshoes-app.backend.livenessProbe" -}}
{{- with .Values.backend.livenessProbe }}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Backend readiness probe
*/}}
{{- define "beeshoes-app.backend.readinessProbe" -}}
{{- with .Values.backend.readinessProbe }}
readinessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Backend startup probe
*/}}
{{- define "beeshoes-app.backend.startupProbe" -}}
{{- with .Values.backend.startupProbe }}
startupProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Database liveness probe
*/}}
{{- define "beeshoes-app.database.livenessProbe" -}}
{{- with .Values.mariadb.livenessProbe }}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Database readiness probe
*/}}
{{- define "beeshoes-app.database.readinessProbe" -}}
{{- with .Values.mariadb.readinessProbe }}
readinessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }} 
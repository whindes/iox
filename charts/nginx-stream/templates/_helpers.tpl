{{/*
Expand the name of the chart.
*/}}
{{- define "nginx-stream.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nginx-stream.fullname" -}}
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
{{- define "nginx-stream.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nginx-stream.labels" -}}
helm.sh/chart: {{ include "nginx-stream.chart" . }}
{{ include "nginx-stream.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nginx-stream.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nginx-stream.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nginx-stream.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nginx-stream.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate certificate name based on TLS host and index
*/}}
{{- define "nginx-stream.certificateName" -}}
{{- $ctx := .ctx -}}
{{- $index := .index -}}
{{- $tls := index $ctx.Values.ingress.tls $index -}}
{{- if $tls.hosts -}}
{{- $firstHost := first $tls.hosts -}}
{{- $sanitizedHost := $firstHost | replace "." "-" | replace "*" "wildcard" -}}
{{- printf "%s-cert-%s" (include "nginx-stream.fullname" $ctx) $sanitizedHost -}}
{{- else -}}
{{- printf "%s-cert-%d" (include "nginx-stream.fullname" $ctx) $index -}}
{{- end -}}
{{- end -}}

{{/*
Get issuer name for certificates
*/}}
{{- define "nginx-stream.issuerName" -}}
{{- if .Values.certManager -}}
{{- if .Values.certManager.issuerRef -}}
{{- .Values.certManager.issuerRef.name -}}
{{- else -}}
{{- "letsencrypt-prod" -}}
{{- end -}}
{{- else -}}
{{- "letsencrypt-prod" -}}
{{- end -}}
{{- end -}}

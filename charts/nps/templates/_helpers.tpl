{{/*
Expand the name of the chart.
*/}}
{{- define "nps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nps.fullname" -}}
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
{{- define "nps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nps.labels" -}}
helm.sh/chart: {{ include "nps.chart" . }}
{{ include "nps.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nps.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Construct the namespace for all namespaced resources
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
Preserve the default behavior of the Release namespace if no override is provided
*/}}
{{- define "nps.namespace" -}}
{{- if .Values.namespaceOverride -}}
{{- .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Common Service
*/}}
{{- define "nps.commonService" }}
{{- $name := index . 0 }}
{{- $global := index . 1 }}
{{- $service := $name | get $global.Values.services | toYaml | fromYaml }}
{{- if $service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ printf "%s-%s" (include "nps.fullname" $global) (kebabcase $name) | trunc 63 | trimSuffix "-" }}
  namespace: {{ template "nps.namespace" $global }}
  labels:
    {{- include "nps.labels" $global | nindent 4 }}
spec:
  type: {{ $service.type }}
  ports:
    - port: {{ $service.port }}
      targetPort: {{ $service.targetPort }}
      protocol: {{ $service.protocol }}
      name: {{ kebabcase $name }}
  selector:
    {{- include "nps.selectorLabels" $global | nindent 4 }}
{{- end -}}
{{- end -}}

{{/*
JSON for tunnels ports
*/}}
{{- define "nps.tunnelsPortsJson" }}
  {{- $tcpPortsMap := dict }}
  {{- $udpPortsMap := dict }}
  {{- range $ports := .Values.portTunnels.ports }}
    {{- $map := dict }}
    {{- if eq $ports.protocol "TCP" }}
      {{- $map = $tcpPortsMap }}
    {{- else if eq $ports.protocol "UDP" }}
      {{- $map = $udpPortsMap }}
    {{- else }}
      {{- fail "Invalid tunnels protocol" }}
    {{- end }}
    {{- range $port := (untilStep (int $ports.start) (int ($ports.end | add 1)) 1) }}
        {{- $_ := set $map (toString $port) nil }}
    {{- end }}
  {{- end }}
  {{- $result := dict "tcp" (keys $tcpPortsMap | sortAlpha) "udp" (keys $udpPortsMap | sortAlpha) }}
  {{- $result | toJson }}
{{- end -}}

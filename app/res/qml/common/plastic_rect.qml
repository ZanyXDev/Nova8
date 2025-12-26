import QtQuick 2.15

Item {
  id: root
  property bool antialiasing: true
  property bool lighting: true
  property bool maxPerformance: true
  property bool isLeftSide: true
  property real roundedCornerRadius: 35
  // === Текстуры ===
  property url albedoMap: "qrc:/res/images/textures/Plastic008_1K-JPG_Color.jpg"
  property url normalMap: "qrc:/res/images/textures/Plastic008_1K-JPG_NormalDX.jpg" // ← используем DirectX-версию
  property url roughnessMap: "qrc:/res/images/textures/Plastic008_1K-JPG_Roughness.jpg"
  property url heightMap: "qrc:/res/images/textures/Plastic008_1K-JPG_Displacement.jpg"

  // === Освещение ===
  property real lightAngle: 45 // азимут (градусы) направление света (0° = справа, 90° = снизу и т.д.)
  property real lightElevation: 45 // высота над поверхностью (градусы)  (0° = горизонт, 90° = сверху)
  property real lightIntensity: 1.5
  property color lightColor: "#ffffff"
  property real metalness: 0.0 // пластик = неметалл
  property real ao: 1.0 // ambient occlusion ( добавить карту позже)

  property real rimDarkness: 0.55 // степень затемнения у края
  property real rimWidth: 55.0 // ширина зоны (в пикселях)
  implicitWidth: 164
  implicitHeight: 360

  ShaderEffect {
    anchors.fill: parent

    // === Размер для геометрии ===
    property size resolution: Qt.size(width, height)

    // Текстуры
    property var texAlbedo: ShaderEffectSource {
      sourceItem: Image {
        source: root.albedoMap
        smooth: true
      }
    }
    property var texNormal: ShaderEffectSource {
      sourceItem: Image {
        source: root.normalMap
        smooth: true
      }
    }
    property var texRough: ShaderEffectSource {
      sourceItem: Image {
        source: root.roughnessMap
        smooth: true
      }
    }
    property var texHeight: ShaderEffectSource {
      sourceItem: Image {
        source: root.heightMap
        smooth: true
      }
    }
    // масштаб высоты (для расчёта производных)
    property real heightScale: 0.02
    // насколько сильно затемнять
    property real aoFromHeightStrength: 0.7
    property real rimDarkness: 0.35
    property real rimWidth: 25.0

    // Для скругления
    property real radius: root.roundedCornerRadius
    property bool roundRight: root.isLeftSide

    // Параметры освещения — передаём в шейдер
    property real lightAzimuthRad: root.lightAngle * 0.0174533
    property real lightElevationRad: root.lightElevation * 0.0174533
    property real lightInt: root.lightIntensity
    property color lightCol: root.lightColor

    // Флаги
    property bool enableLighting: root.lighting
    property bool enableAA: root.antialiasing
    property bool perfMode: root.maxPerformance
    // Шейдер
    fragmentShader: "
#ifdef GL_ES
precision highp float;
#endif

uniform float radius;
uniform bool roundRight;
uniform bool enableAA;
uniform bool enableLighting;
uniform bool perfMode;

uniform vec2 resolution;
uniform sampler2D texAlbedo;
uniform sampler2D texNormal;
uniform sampler2D texRough;

uniform float lightAzimuthRad;
uniform float lightElevationRad;
uniform float lightInt;
uniform vec4 lightCol;

uniform float rimDarkness;
uniform float rimWidth;

uniform sampler2D texHeight;
uniform float heightScale;
uniform float aoFromHeightStrength;

varying vec2 qt_TexCoord0;

// Возвращает тёмный коэффициент на краях рельефа
float calculatePseudoAO(sampler2D heightMap, vec2 uv, vec2 texelSize, float strength) {
float h = texture2D(heightMap, uv).r;

// Берём соседние пиксели
float hN = texture2D(heightMap, uv + vec2(0.0, -texelSize.y)).r;
float hS = texture2D(heightMap, uv + vec2(0.0,  texelSize.y)).r;
float hE = texture2D(heightMap, uv + vec2( texelSize.x, 0.0)).r;
float hW = texture2D(heightMap, uv + vec2(-texelSize.x, 0.0)).r;

// Градиенты
vec2 grad = vec2(hE - hW, hN - hS) * 0.5;

// Магнитуда градиента = насколько резко меняется высота
float edge = length(grad);

// Чем резче край — тем темнее (AO)
// Но инвертируем: в глубоких трещинах тоже темно → можно использовать второй проход
// Пока используем простую формулу
float ao = 1.0 - edge * strength;

// Ограничиваем, чтобы не было светлее 1
return clamp(ao, 0.3, 1.0);
}

// Упрощённая функция сглаживания скругления
float roundedBoxSDF(vec2 p, vec2 b, float r) {
vec2 q = abs(p) - b + r;
return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}
// Функция для скругления только с одной стороны
float sideRoundedRectSDF(vec2 uv, vec2 size, float radius, bool roundRightSide) {
vec2 center = size * 0.5;
vec2 p = uv - center;
float w = size.x * 0.5;
float h = size.y * 0.5;
float r = min(radius, h);

if (r <= 0.01) {
return max(abs(p.x) - w, abs(p.y) - h);
}

if (roundRightSide) {
if (p.x >= 0.0) {
return roundedBoxSDF(p, vec2(w, h), r);
} else {
return max(abs(p.x) - w, abs(p.y) - h);
}
} else {
if (p.x <= 0.0) {
return roundedBoxSDF(p, vec2(w, h), r);
} else {
return max(abs(p.x) - w, abs(p.y) - h);
}
}
}

void main() {


vec2 texelSize = 1.0 / resolution;
float pseudoAO = 1.0;
if (!perfMode) {
pseudoAO = calculatePseudoAO(texHeight, qt_TexCoord0, texelSize, aoFromHeightStrength);
}

vec2 uv = qt_TexCoord0 * resolution;
vec2 size = resolution;

float d = sideRoundedRectSDF(uv, size, radius, roundRight);

float alpha = 1.0;
if (enableAA) {
float coverage = smoothstep(-1.0, 1.0, -d);
alpha = coverage;
} else {
if (d > 0.0) discard;
}
if (alpha <= 0.0) discard;

vec3 albedo = texture2D(texAlbedo, qt_TexCoord0).rgb;
vec3 normal = texture2D(texNormal, qt_TexCoord0).rgb;
normal = normal * 2.0 - 1.0;
normal.y = -normal.y;
normal = normalize(normal);

float roughness = perfMode ? 0.3 : texture2D(texRough, qt_TexCoord0).r;

float edgeDist = -d;
float rimFactor = smoothstep(0.0, rimWidth, edgeDist);
float rimOcclusion = mix(1.0 - rimDarkness, 1.0, rimFactor);
float totalOcclusion = pseudoAO * rimOcclusion;

vec3 color = albedo * totalOcclusion;

if (enableLighting) {
vec3 lightDir;
lightDir.x = cos(lightAzimuthRad) * cos(lightElevationRad);
lightDir.y = sin(lightAzimuthRad) * cos(lightElevationRad);
lightDir.z = sin(lightElevationRad);
lightDir = normalize(lightDir);

float NdotL = max(dot(normal, lightDir), 0.0);
vec3 diffuse = albedo * NdotL;

vec3 viewDir = vec3(0.0, 0.0, 1.0);
vec3 halfDir = normalize(lightDir + viewDir);
float NdotH = max(dot(normal, halfDir), 0.0);
float spec = pow(NdotH, 256.0 * (1.0 - roughness + 0.01));

vec3 specular = vec3(0.04) * spec * lightInt; // f0 = 0.04 для пластика

color = (diffuse + specular) * lightCol.rgb;
color *= totalOcclusion;
}

gl_FragColor = vec4(color, alpha);
}
"
  }
}

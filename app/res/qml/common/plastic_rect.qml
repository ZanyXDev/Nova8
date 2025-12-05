import QtQuick 2.15

Item {
  id: root
  property bool antialiasing: true
  property bool lighting: true
  property bool maxPerfomance: true
  property bool isLeftSide: true
  property real roundedCornerRaduis: 35
  // === Текстуры ===
  property url albedoMap: "qrc:/res/images/textures/Plastic008_1K-JPG_Color.jpg"
  property url normalMap: "qrc:/res/images/textures/Plastic008_1K-JPG_NormalDX.jpg" // ← используем DirectX-версию
  property url roughnessMap: "qrc:/res/images/textures/Plastic008_1K-JPG_Roughness.jpg"

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

    // Для скругления
    property real radius: root.roundedCornerRaduis
    property bool roundRight: root.isLeftSide

    // Параметры освещения — передаём в шейдер
    property real lightAzimuthRad: root.lightAngle * 0.0174533
    property real lightElevationRad: root.lightElevation * 0.0174533
    property real lightInt: root.lightIntensity
    property color lightCol: root.lightColor

    property real rimDarkness: root.rimDarkness
    property real rimWidth: root.rimWidth

    // Флаги
    property bool enableLighting: root.lighting
    property bool enableAA: root.antialiasing
    property bool perfMode: root.maxPerfomance
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

varying vec2 qt_TexCoord0;

// Упрощённая функция сглаживания скругления
float roundedBoxSDF(vec2 p, vec2 b, float r) {
vec2 q = abs(p) - b + r;
return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

// Функция для скругления только с одной стороны
float sideRoundedRectSDF(vec2 uv, vec2 size, float r, bool roundRightSide) {
vec2 center = size * 0.5;
vec2 p = uv - center;

vec2 halfSize = size * 0.5;
halfSize.x -= r; // уменьшаем по X, чтобы радиус не вылезал

if (roundRightSide) {
// Скругляем ПРАВУЮ сторону
if (p.x > 0.0) {
return roundedBoxSDF(p, halfSize, r);
} else {
// Левая сторона — прямая
return max(abs(p.y) - halfSize.y, -p.x - halfSize.x);
}
} else {
// Скругляем ЛЕВУЮ сторону
if (p.x < 0.0) {
return roundedBoxSDF(p, halfSize, r);
} else {
// Правая сторона — прямая
return max(abs(p.y) - halfSize.y, p.x - halfSize.x);
}
}
}

void main() {
vec2 uv = qt_TexCoord0 * resolution;
vec2 size = resolution;

float d = sideRoundedRectSDF(uv, size, radius, roundRight);

// Альфа-канал и обрезка
float alpha = 1.0;
if (enableAA) {
float coverage = smoothstep(-1.0, 1.0, -d);
alpha = coverage;
} else {
if (d > 0.0) discard;
}
if (alpha <= 0.0) discard;

// Базовые текстуры
vec3 albedo = texture2D(texAlbedo, qt_TexCoord0).rgb;
vec3 normal = texture2D(texNormal, qt_TexCoord0).rgb;
normal = normal * 2.0 - 1.0;
normal.y = -normal.y;
normal = normalize(normal);

float roughness = perfMode ? 0.8 : texture2D(texRough, qt_TexCoord0).r;

// === ЭФФЕКТ ОБЪЁМА: затемнение у краёв ===
float edgeDist = -d; // внутри фигуры: d < 0 → edgeDist > 0
float rimFactor = smoothstep(0.0, rimWidth, edgeDist); // 0 у края, 1 в центре
float occlusion = mix(1.0 - rimDarkness, 1.0, rimFactor); // темнее у края

vec3 color = albedo * occlusion;

if (enableLighting) {
vec3 lightDir;
lightDir.x = cos(lightAzimuthRad) * cos(lightElevationRad);
lightDir.y = sin(lightAzimuthRad) * cos(lightElevationRad);
lightDir.z = sin(lightElevationRad);
lightDir = normalize(lightDir);

// Diffuse
float NdotL = max(dot(normal, lightDir), 0.0);
vec3 diffuse = albedo * NdotL;

// Specular (Blinn-style)
vec3 viewDir = vec3(0.0, 0.0, 1.0);
vec3 halfDir = normalize(lightDir + viewDir);
float NdotH = max(dot(normal, halfDir), 0.0);
float spec = pow(NdotH, 256.0 * (1.0 - roughness + 0.01));

vec3 specular = vec3(0.0); // non-metal
if (!perfMode) {
specular = albedo * spec * 0.5; // слегка добавим specular от альбедо даже для пластика
}

color = (diffuse + specular * lightInt) * lightCol.rgb;
color *= occlusion; // освещение тоже затемняется у краёв
}

gl_FragColor = vec4(color, alpha);
}
"
  }
}

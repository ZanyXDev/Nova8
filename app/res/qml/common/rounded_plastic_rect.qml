import QtQuick 2.15

Item {
  id: root

  // === Геометрия ===
  property real cornerRadius: 20
  property bool roundRight: true

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
  property real ao: 1.0 // ambient occlusion (можно добавить карту позже)

  implicitWidth: 186
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

    // Геометрия
    property real radius: root.cornerRadius
    property bool roundRight: root.roundRight

    // Свет
    property vector3d lightDir: Qt.vector3d(
                                  Math.cos(root.lightAngle * Math.PI / 180) * Math.cos(root.lightElevation * Math.PI / 180),
                                  Math.sin(root.lightAngle * Math.PI / 180) * Math.cos(root.lightElevation * Math.PI / 180),
                                  Math.sin(root.lightElevation * Math.PI / 180))
    property real intensity: root.lightIntensity
    property real metalness: root.metalness
    property vector3d lightCol: Qt.vector3d(root.lightColor.r / 255.0, root.lightColor.g / 255.0,
                                            root.lightColor.b / 255.0)

    vertexShader: "
uniform highp mat4 qt_Matrix;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 qt_TexCoord0;
void main() {
qt_TexCoord0 = qt_MultiTexCoord0;
gl_Position = qt_Matrix * qt_Vertex;
}
"

    fragmentShader: "
varying highp vec2 qt_TexCoord0;
uniform highp vec2 resolution;
uniform sampler2D texAlbedo;
uniform sampler2D texNormal;
uniform sampler2D texRough;

uniform highp float radius;
uniform bool roundRight;

uniform highp vec3 lightDir;
uniform highp float intensity;
uniform highp float metalness;
uniform highp vec3 lightCol;

// Проверка формы (закругление)
bool inShape(highp vec2 p, highp vec2 size) {
// Закругление
if (roundRight) {
if (p.x > size.x - radius) {
if (p.y < radius && distance(p, vec2(size.x - radius, radius)) > radius) return false;
if (p.y > size.y - radius && distance(p, vec2(size.x - radius, size.y - radius)) > radius) return false;
}
}

return true;
}

// Упрощённый PBR-шейдинг (на основе https://learnopengl.com/PBR/Lighting)
highp vec3 fresnelSchlick(highp float cosTheta, highp vec3 F0) {
return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

void main() {
highp vec2 uv = qt_TexCoord0;
highp vec2 pos = uv * resolution;

if (!inShape(pos, resolution)) {
gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
return;
}

// === Загрузка карт ===
highp vec3 albedo = pow(texture2D(texAlbedo, uv).rgb, vec3(2.2)); // sRGB → linear
//для отладки
//highp vec3 albedo = vec3(0.8, 0.2, 0.2); // Ярко-красный

highp vec3 normal = texture2D(texNormal, uv).rgb;
normal = normalize(normal * 2.0 - 1.0); // [0,1] → [-1,1]
highp float roughness = texture2D(texRough, uv).r;
highp float metallic = metalness;

// === PBR параметры ===
highp vec3 N = normal;
highp vec3 V = vec3(0.0, 0.0, 1.0); // камера сверху
highp vec3 L = normalize(lightDir);
highp vec3 H = normalize(L + V);

highp float NdotL = clamp(dot(N, L), 0.001, 1.0);
highp float NdotV = clamp(dot(N, V), 0.001, 1.0);
highp float NdotH = clamp(dot(N, H), 0.0, 1.0);
highp float VdotH = clamp(dot(V, H), 0.0, 1.0);

// === F0 (базовое отражение) ===
highp vec3 F0 = mix(vec3(0.04), albedo, metallic);

// === Френель ===
highp vec3 F = fresnelSchlick(VdotH, F0);

// === Распределение (GGX Trowbridge-Reitz) ===
highp float alpha = roughness * roughness;
highp float alpha2 = alpha * alpha;
highp float denom = NdotH * NdotH * (alpha2 - 1.0) + 1.0;
highp float D = alpha2 / (3.14159265 * denom * denom + 0.0001);

// === Геометрия (Smith) ===
highp float k = (roughness + 1.0) * (roughness + 1.0) / 8.0;
highp float G1L = NdotL / (NdotL * (1.0 - k) + k);
highp float G1V = NdotV / (NdotV * (1.0 - k) + k);
highp float G = G1L * G1V;

// === Cook-Torrance specular ===
highp vec3 numerator = F * D * G;
highp float denominator = 4.0 * NdotL * NdotV + 0.0001;
highp vec3 specular = numerator / denominator;

// === Diffuse ===
highp vec3 kS = F; // зеркальная часть
highp vec3 kD = vec3(1.0) - kS; // диффузная часть
kD *= 1.0 - metallic;

highp vec3 diffuse = kD * albedo / 3.14159265;

// === Итоговый цвет ===
highp vec3 color = (diffuse + specular) * lightCol * NdotL;
color = pow(color, vec3(1.0/2.2)); // linear → sRGB

gl_FragColor = vec4(color * intensity, 1.0);
}
"
  }
}

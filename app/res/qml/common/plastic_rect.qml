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

    // Геометрия
    property real radius: root.roundedCornerRaduis
    property bool roundRight: root.isLeftSide
  }
}

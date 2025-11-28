#include <QtCore/QCoreApplication>

#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>

#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras/QtAndroid>
#include <QtAndroidExtras/QAndroidJniObject>
#include <QtAndroidExtras/QAndroidJniEnvironment>
#else
#include <QtGui/QScreen>
#endif

#ifdef QT_DEBUG
#include <QtCore/QDirIterator>
#include <QtCore/QLoggingCategory>
#endif

#include "hal.h"
#include "imageprovider.h"
#include "engine.h"

int main(int argc, char *argv[]) {
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_DisableHighDpiScaling);
#endif
    QScopedPointer<Engine> m_engine(new Engine);
    // Allocate [Hal] before the engine to ensure that it outlives it !!
    QScopedPointer<Hal> m_hal(new Hal);   
    m_hal->createAppFolder();

    QCoreApplication::setOrganizationName(PACKAGE_NAME_STR);
    QCoreApplication::setApplicationName(ACTIVITY_NAME_STR);
    QCoreApplication::setApplicationVersion(VERSION_STR);
    QGuiApplication app(argc, argv);

#ifdef QT_DEBUG
    QLoggingCategory::setFilterRules(QStringLiteral("qt.qml.binding.removal.info=true"));
#endif
    /**
     * @brief myappTranslator
     */
    /// TODO add translations
    //    QTranslator myappTranslator;
    //    myappTranslator.load(QLocale(),
    //                         QLatin1String("delight"),
    //                         QLatin1String("_"),
    //                         QLatin1String(":/i18n"));
    //    app.installTranslator(&myappTranslator);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/res/qml");
    QQmlContext *context = engine.rootContext();
    // Регистрируем провайдера изображений
    ImageProvider *imageProvider = new ImageProvider();
    engine.addImageProvider("virtual_screen", imageProvider);
    m_engine->setImageProvider(imageProvider);

#ifdef Q_OS_ANDROID    
    QtAndroid::hideSplashScreen();
#else
    QScreen *screen = qApp->primaryScreen();
    m_hal->setDotsPerInch( screen->physicalDotsPerInch() );
    m_hal->setDevicePixelRatio( screen->devicePixelRatio() );
#endif
    context->setContextProperty("mm",m_hal->getDevicePixelRatio() / 25.4);
    context->setContextProperty("pt", 1);
    context->setContextProperty("AppVersion",VERSION_STR);
    context->setContextProperty("isDebugMode", m_hal->getDebugMode() );    
    context->setContextProperty("DevicePixelRatio", m_hal->getDevicePixelRatio());
    context->setContextProperty("isMobile",m_hal->isRunOnMobile());
    const QUrl url(QStringLiteral("qrc:/res/qml/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](const QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    // https://raymii.org/s/articles/Qt_QML_Integrate_Cpp_with_QML_and_why_ContextProperties_are_bad.html

    // Register the singleton type provider with QML by calling this
    // function in an initialization function.
    qmlRegisterSingletonInstance("io.github.zanyxdev.nova8.hal", 1, 0,"HAL", m_hal.get());
    qmlRegisterSingletonInstance("io.github.zanyxdev.nova8.engine", 1, 0,"ENGINE", m_engine.get());
    engine.load(url);

    return app.exec();
}

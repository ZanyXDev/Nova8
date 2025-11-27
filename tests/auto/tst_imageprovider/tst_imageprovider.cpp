#include "tst_imageprovider.h"

#include <QtTest/QtTest>


void TestImageProvider::initTestCase()
{
    m_imageProvider = new ImageProvider();
    engine.addImageProvider("tst_imageprovider_1",  m_imageProvider );

    auto tst_imageprovider_1 = engine.imageProvider("tst_imageprovider_1");
    QVERIFY2(tst_imageprovider_1 != nullptr,"Custom tst_imageprovider_1 not set");

    auto tst_imageprovider_2 = engine.imageProvider("tst_imageprovider_2");
    QVERIFY2(tst_imageprovider_2 == nullptr,"Custom tst_imageprovider_2 set but not added");
}

void TestImageProvider::init()
{

}

void TestImageProvider::cleanupTestCase()
{

}

void TestImageProvider::testRequestImage()
{
    QFETCH(QString, imageId);
    QFETCH(bool,isExist);
    QFETCH(int,sizeWidth);
    QFETCH(int,sizeHeight);
    QFETCH(int,reqSizeWidth);
    QFETCH(int,reqSizeHeight);

    QSize actualSize;
    QImage image;

    image = m_imageProvider->requestImage(imageId, &actualSize,
                                          QSize(reqSizeWidth, reqSizeHeight));

    QCOMPARE(image.isNull(),isExist); // Verify image is not null
    QCOMPARE(image.width(), sizeWidth); // Verify image width
    QCOMPARE(image.height(), sizeHeight); // Verify image height
    QCOMPARE(actualSize, QSize(reqSizeWidth, reqSizeHeight)); // Verify reported size

    //image = m_imageProvider->requestImage("unused", nullptr, QSize());

}

void TestImageProvider::testRequestImage_data()
{
    QTest::addColumn<QString>("imageId");
    QTest::addColumn<bool>("isExist");
    QTest::addColumn<int>("sizeWidth");
    QTest::addColumn<int>("sizeHeight");
    QTest::addColumn<int>("reqSizeWidth");
    QTest::addColumn<int>("reqSizeHeight");

    QTest::newRow("valid_8x8x4_pic_img") << "true_true_8x8x4" << true  << 208 << 208 << 208 << 208;
    QTest::newRow("request_wrong_image") << "wrong_image"     << false << -1  << -1  << 0   << 0;
}



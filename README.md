# JunVisionFace
## Demo支持 
- 文字识别
- 矩形识别
- 条码识别
- 人脸特征识别
- 静态人脸识别
- 动态人脸识别
- 实时动态添加
- 对象检测和跟踪

##### 简书地址: [Swift之Vision 图像识别框架](http://www.jianshu.com/p/08174663d2e9)
##### CSDN博客地址: [Swift之Vision 图像识别框架](http://blog.csdn.net/ShmilyCoder/article/details/78667041)


# Swift之Vision 图像识别框架

- 2017年苹果大大又推出了新机型iPhone 8和iPhone 8Plus, 这还不是重点, 重点是那一款价值9000RMB的iPhone X, 虽说网上吐槽声从未停止过, 但是我觉得还是不错的哈!
- 软件方面, 苹果大大也推出了iOS 11, 经本人iPhone 7手机亲测, 耗电快外加通知栏改不完的bug
- 当然了随着iOS 11的推出, 也随之推出了一些新的API，如：[`ARKit`](https://developer.apple.com/documentation/arkit) 、[`Core ML`](https://developer.apple.com/documentation/coreml)、[`FileProvider`](https://developer.apple.com/documentation/fileprovider)、[`IdentityLookup`](https://developer.apple.com/documentation/identitylookup) 、[`Core NFC`](https://developer.apple.com/documentation/corenfc)、[`Vison`](https://developer.apple.com/documentation/vision) 等。
- 这里我们还要说的就是Apple 在 WWDC 2017 推出的图像识别框架--`Vison`[官方文档](https://developer.apple.com/documentation/vision)
- [Demo地址](https://github.com/coderQuanjun/JunVisionFace)

## 一. Vision应用场景
- `Face Detection and Recognition` : 人脸检测
  - 支持检测笑脸、侧脸、局部遮挡脸部、戴眼镜和帽子等场景，可以标记出人脸的矩形区域
  - 可以标记出人脸和眼睛、眉毛、鼻子、嘴、牙齿的轮廓，以及人脸的中轴线
- `Image Alignment Analysis`: 图像对比分析
- `Barcode Detection`: 二维码/条形码检测
  - 用于查找和识别图像中的条码
  - 检测条形码信息
- `Text Detection`: 文字检测
  - 查找图像中可见文本的区域
  - 检测文本区域的信息
- `Object Detection and Tracking`: 目标跟踪
  - 脸部，矩形和通用模板

## 二. Vision支持的图片类型
### 1. Objective-C中
- `CVPixelBufferRef`
- `CGImageRef`
- `CIImage`
- `NSURL`
- `NSData`
 
### 2. Swift中
- `CVPixelBuffer`
- `CGImage`
- `CIImage`
- `URL`
- `Data`

> 具体详情可在`Vision.framework`的`VNImageRequestHandler.h`文件中查看

## 三. Vision之API介绍
- 使用在`vision`的时候，我们首先需要明确自己需要什么效果，然后根据想要的效果来选择不同的类
- 给各种功能的 `Request` 提供给一个 `RequestHandler`
- `Handler` 持有需要识别的图片信息，并将处理结果分发给每个 `Request` 的 `completion Block` 中
- 可以从 `results` 属性中得到 `Observation` 数组
- `observations`数组中的内容根据不同的request请求返回了不同的`observation`
- 每种`Observation`有`boundingBox`，`landmarks`等属性，存储的是识别后物体的坐标，点位等
- 我们拿到坐标后，就可以进行一些UI绘制。

### 1. `RequestHandler`处理请求对象
- `VNImageRequestHandler`: 处理与单个图像有关的一个或多个图像分析请求的对象
  - 一般情况下都是用该类处理识别请求
  - 初始化方法支持`CVPixelBuffer`, `CGImage`, `CIImage`, `URL`, `Data`
- `VNSequenceRequestHandler`: 处理与多个图像序列有关的图像分析请求的对象
  - 目前我在处理物体跟踪的时候使用该类
  - 初始化方法同上
  
### 2. VNRequest介绍
- `VNRequest`: 图像分析请求的抽象类, 继承于`NSObject`
- `VNBaseImageRequest`: 专注于图像的特定部分的分析请求
- 具体分析请求类如下: 
- 
![VNImageBasedRequest.png](http://upload-images.jianshu.io/upload_images/4122543-b58783bec9d07551.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 3. `VNObservation`检测对象
- `VNObservation`: 图像分析结果的抽象类, 继承与`NSObject`
- 图像检测结果的相关处理类如下:
- 
![VNObservation.png](http://upload-images.jianshu.io/upload_images/4122543-c0b83aa723e149ab.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 四. 实战演练
### 1. 文本检测
- 方式一: 识别出具体的每一个字体的位置信息
- 方式二: 识别一行字体的位置信息
- 如图效果:
- 
![WechatIMG3.jpeg](http://upload-images.jianshu.io/upload_images/4122543-0c09426c80013322.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/300)

![WechatIMG5.jpeg](http://upload-images.jianshu.io/upload_images/4122543-8b970c464c26ffb0.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/300)

#### 1.1 现将图片转成初始化`VNImageRequestHandler`对象时, 可接受的的`CIImage`

```
//1. 转成ciimage
guard let ciImage = CIImage(image: image) else { return }
```

#### 1.2 创建处理请求的handle
- 参数一: 图片类型
- 参数二: 字典类型, 有默认值为[:]

```
let requestHandle = VNImageRequestHandler(ciImage: ciImage, options: [:])
```

#### 1.3 创建回调闭包
- 两个参数, 无返回值
- `VNRequest`: 是所有请求Request的父类

```
public typealias VNRequestCompletionHandler = (VNRequest, Error?) -> Swift.Void

```
- 具体代码如下: 

```objc
//4. 设置回调
let completionHandle: VNRequestCompletionHandler = { request, error in
    let observations = request.results
    //识别出来的对象数组    
}

```

#### 1.4 创建识别请求
- 两种初始化方式

```objc
//无参数
public convenience init()
    
//闭包参数
public init(completionHandler: Vision.VNRequestCompletionHandler? = nil)

```
- 这里使用带闭包的初始化方式

```
let baseRequest = VNDetectTextRectanglesRequest(completionHandler: completionHandle)
```

- 属性设置(是否识别具体的每一个文字)

```
// 设置识别具体文字
baseRequest.setValue(true, forKey: "reportCharacterBoxes") 
```
- 不设置该属性, 识别出来的是一行文字

#### 1.5 发送请求

```
    open func perform(_ requests: [VNRequest]) throws
```

- 该方法会抛出一个异常错误
- 在连续不断(摄像头扫描)发送请求过程中, 必须在子线程执行该方法, 否则会造成线程堵塞

```objc
//6. 发送请求
DispatchQueue.global().async {
    do{
        try requestHandle.perform([baseRequest])
    }catch{
        print("Throws：\(error)")
    }
}

```

#### 1.6 处理识别的`Observations`对象
- 识别出来的`results`是`[Any]?`类型
- 根据`boundingBox`属性可以获取到对应的文本区域的尺寸
- 需要注意的是:
  - `boundingBox`得到的是相对iamge的比例尺寸, 都是小于1的
  - Y轴坐标于UIView坐标系是相反的

```objc
//1. 获取识别到的VNTextObservation
guard let boxArr = observations as? [VNTextObservation] else { return }
        
//2. 创建rect数组
var bigRects = [CGRect](), smallRects = [CGRect]()
        
//3. 遍历识别结果
for boxObj in boxArr {
    // 3.1尺寸转换
    //获取一行文本的区域位置
    bigRects.append(convertRect(boxObj.boundingBox, image))
    
    //2. 获取
    guard let rectangleArr = boxObj.characterBoxes else { continue }
    for rectangle in rectangleArr{
        //3. 得到每一个字体的的尺寸
        let boundBox = rectangle.boundingBox
        smallRects.append(convertRect(boundBox, image))
    }
}

```

> 坐标转换

```objc
/// image坐标转换
fileprivate func convertRect(_ rectangleRect: CGRect, _ image: UIImage) -> CGRect {
//此处是将Image的实际尺寸转化成imageView的尺寸
    let imageSize = image.scaleImage()
    let w = rectangleRect.width * imageSize.width
    let h = rectangleRect.height * imageSize.height
    let x = rectangleRect.minX * imageSize.width
    //该Y坐标与UIView的Y坐标是相反的
    let y = (1 - rectangleRect.minY) * imageSize.height - h
    return CGRect(x: x, y: y, width: w, height: h)
}

```

### 2. 矩形识别和静态人脸识别
- 识别图像中的矩形
- 
![1511935758595.jpg](http://upload-images.jianshu.io/upload_images/4122543-05e6a9cc6c193b1d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

- 静态人脸识别
- 
![1511936019734.jpg](http://upload-images.jianshu.io/upload_images/4122543-e5faf93cebae945e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

- 主要核心代码
- 

```
//1. 转成ciimage
guard let ciImage = CIImage(image: image) else { return }
        
//2. 创建处理request
let requestHandle = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
//3. 创建baseRequest
//大多数识别请求request都继承自VNImageBasedRequest
var baseRequest = VNImageBasedRequest()
        
//4. 设置回调
let completionHandle: VNRequestCompletionHandler = { request, error in
    let observations = request.results
    self.handleImageObservable(type: type, image: image, observations, completeBack)
}
        
//5. 创建识别请求
switch type {
case .rectangle:
    baseRequest = VNDetectRectanglesRequest(completionHandler: completionHandle)
case .staticFace:
    baseRequest = VNDetectFaceRectanglesRequest(completionHandler: completionHandle)
default:
    break
}

```

- 处理识别的observation

```objc
    /// 矩形检测
    fileprivate func rectangleDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: JunDetectHandle){
        //1. 获取识别到的VNRectangleObservation
        guard let boxArr = observations as? [VNRectangleObservation] else { return }
        //2. 创建rect数组
        var bigRects = [CGRect]()
        //3. 遍历识别结果
        for boxObj in boxArr {
            // 3.1
            bigRects.append(convertRect(boxObj.boundingBox, image))
        }
        //4. 回调结果
        complecHandle(bigRects, [])
    }

```

- 静态人脸识别需要将`observation`转成`VNFaceObservation`

```
guard let boxArr = observations as? [VNFaceObservation] else { return }
```

### 3. 条码识别

![1511936988374.jpg](http://upload-images.jianshu.io/upload_images/4122543-9f199a027f186a5c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

- 这里请求的步骤与矩形识别相同, 这里不再赘述
- 需要注意的是,在初始化request的时候需要设一个置可识别的条码类型参数
- 这里先看一下`VNDetectBarcodesRequest`的两个参数

```
//支持的可识别的条码类型(需要直接用class调用)
open class var supportedSymbologies: [VNBarcodeSymbology] { get }

//设置可识别的条码类型
open var symbologies: [VNBarcodeSymbology]
```

- 此处设置可识别到的条码类型为, 该请求支持是别的所有类型, 如下
- 注意`supportedSymbologies`参数的调用方法

```objc
let request = VNDetectBarcodesRequest(completionHandler: completionHandle)
request.symbologies = VNDetectBarcodesRequest.supportedSymbologies
```

- 条码识别不但能识别条码的位置信息, 还可以识别出条码的相关信息, 这里以二维码为例
- 这里需要将识别的`observations`转成`[VNBarcodeObservation]`
- `VNBarcodeObservation`有三个属性

```objc
//条码类型: qr, code128....等等
open var symbology: VNBarcodeSymbology { get }

//条码的相关信息
open var barcodeDescriptor: CIBarcodeDescriptor? { get }

//如果是二维码, 则是二维码的网址链接    
open var payloadStringValue: String? { get }
```

- 如上述图片识别出来的`payloadStringValue`参数则是小编的[简书地址](http://www.jianshu.com/u/5bd5e9ed569e)
- 下面是以上述图片的二维码为例处理的`CIBarcodeDescriptor`对象
- 有兴趣的可以仔细研究研究

```objc
    /// 二维码信息处理
    fileprivate func qrCodeHandle(barCode: CIBarcodeDescriptor?){
        //1. 转成对应的条码对象
        guard let code = barCode as? CIQRCodeDescriptor else { return }
        
        //2. 解读条码信息
        let level = code.errorCorrectionLevel.hashValue
        let version = code.symbolVersion
        let mask = code.maskPattern
        let data = code.errorCorrectedPayload
        let dataStr = String(data: data, encoding: .utf8)
        print("这是二维码信息--", level, "---", version, "----", mask, "---", dataStr ?? "")
    }

```

### 4. 人脸特征识别
- 可识别出人脸的轮廓, 眼睛, 鼻子, 嘴巴等具体位置
- 
![1511944652200.jpg](http://upload-images.jianshu.io/upload_images/4122543-895670df5fd8e2c9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)


- `VNFaceLandmarks2D`介绍
- 

```objc
    /// 脸部轮廓
    var faceContour: VNFaceLandmarkRegion2D?
    
    /// 左眼, 右眼
    var leftEye: VNFaceLandmarkRegion2D?
    var rightEye: VNFaceLandmarkRegion2D?
    
    /// 左睫毛, 右睫毛
    var leftEyebrow: VNFaceLandmarkRegion2D?
    var rightEyebrow: VNFaceLandmarkRegion2D?
    
    /// 左眼瞳, 右眼瞳
    var leftPupil: VNFaceLandmarkRegion2D?
    var rightPupil: VNFaceLandmarkRegion2D?
    
    /// 鼻子, 鼻嵴, 正中线
    var nose: VNFaceLandmarkRegion2D?
    var noseCrest: VNFaceLandmarkRegion2D?
    var medianLine: VNFaceLandmarkRegion2D?
    
    /// 外唇, 内唇
    var outerLips: VNFaceLandmarkRegion2D?
    var innerLips: VNFaceLandmarkRegion2D?
```

```
//某一部位所有的像素点
@nonobjc public var normalizedPoints: [CGPoint] { get }

//某一部位的所有像素点的个数
open var pointCount: Int { get }
```

- 将所有的像素点坐标转换成image对应的尺寸坐标
- 使用图像上下文, 对应部位画线
- 在UIView中重写`func draw(_ rect: CGRect)`方法
- 

```objc
//5.1 获取当前上下文
let content = UIGraphicsGetCurrentContext()
                
//5.2 设置填充颜色(setStroke设置描边颜色)
UIColor.green.set()
                
//5.3 设置宽度
content?.setLineWidth(2)
                
//5.4. 设置线的类型(连接处)
content?.setLineJoin(.round)
content?.setLineCap(.round)
                
//5.5. 设置抗锯齿效果
content?.setShouldAntialias(true)
content?.setAllowsAntialiasing(true)
                
//5.6 开始绘制
content?.addLines(between: pointArr)
content?.drawPath(using: .stroke)
                
//5.7 结束绘制
content?.strokePath()
```

### 5. 动态人脸识别和实时动态添加
> 由于真机不好录制gif图(尝试了一下, 效果不是很好, 放弃了), 想看效果的朋友[下载源码](https://github.com/coderQuanjun/JunVisionFace)真机运行吧

- `request`的初始化这里就不做介绍了, 说一下`handle`的初始化方法
  - `CVPixelBuffer`: 扫描实时输出的对象

```
//1. 创建处理请求
let faceHandle = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

```

- 主要强调一点, 相机扫描, 获取实时图像的过程, 必须在子线程执行, 否在会堵塞线程, 整个app失去响应, 亲自踩过的坑

```
DispatchQueue.global().async {
    do{
        try faceHandle.perform([baseRequest])
    }catch{
        print("Throws：\(error)")
    }
}
```

#### 扫描结果处理
- 动态人脸识别和静态人脸识别不同的地方就是, 动态实时刷新, 更新UI, 所以处理结果的方法相同
- 动态添加: 这里处理方式是添加一个眼镜效果
- 这里需要获取到两只眼睛的位置和宽度
  - 先获取到左右眼的所有的像素点和像素点的个数
  - 遍历所有的像素点, 转换成合适的坐标
  - 将左右眼的所有的point, 分别获取X和Y坐标放到不同的数组
  - 将数组有小到大排序, 得到X的最大和最小的差值, Y的最大和最小的差值
  - 具体代码如下

```objc
    /// H偶去转换后的尺寸坐标
    fileprivate func getEyePoint(faceModel: FaceFeatureModel, position: AVCaptureDevice.Position) -> CGRect{
        //1. 获取左右眼
        guard let leftEye = faceModel.leftEye else { return CGRect.zero }
        guard let rightEye = faceModel.rightEye else { return CGRect.zero }

        //2. 位置数组
        let leftPoint = conventPoint(landmark: leftEye, faceRect: faceModel.faceObservation.boundingBox, position: position)
        let rightPoint = conventPoint(landmark: rightEye, faceRect: faceModel.faceObservation.boundingBox, position: position)

        //3. 排序
        let pointXs = (leftPoint.0 + rightPoint.0).sorted()
        let pointYs = (leftPoint.1 + rightPoint.1).sorted()
        
        //4. 添加眼睛
        let image = UIImage(named: "eyes")!
        let imageWidth = (pointXs.last ?? 0.0) - (pointXs.first ?? 0) + 40
        let imageHeight = image.size.height / image.size.width * imageWidth
        
        return CGRect(x: (pointXs.first ?? 0) - 20, y: (pointYs.first ?? 0) - 5, width: imageWidth, height: imageHeight)
    }

```

- 每一只眼睛的坐标处理

```objc
    /// 坐标转换
    fileprivate func conventPoint(landmark: VNFaceLandmarkRegion2D, faceRect: CGRect, position: AVCaptureDevice.Position) -> ([CGFloat], [CGFloat]){
        //1. 定义
        var XArray = [CGFloat](), YArray = [CGFloat]()
        let viewRect = previewLayer.frame
        
        //2. 遍历
        for i in 0..<landmark.pointCount {
            //2.1 获取当前位置并转化到合适尺寸
            let point = landmark.normalizedPoints[i]
            let rectWidth = viewRect.width * faceRect.width
            let rectHeight = viewRect.height * faceRect.height
            let rectY = viewRect.height - (point.y * rectHeight + faceRect.minY * viewRect.height)
            var rectX = point.x * rectWidth + faceRect.minX * viewRect.width
            if position == .front{
                rectX = viewRect.width + (point.x - 1) * rectWidth
            }
            XArray.append(rectX)
            YArray.append(rectY)
        }
        
        return (XArray, YArray)
    }

```

- 最后获取到该`CGRect`, 添加眼镜效果即可


### 6. 物体跟踪
- 简介
  - 我们在屏幕上点击某物体, 然后Vision就会根据点击的物体, 实时跟踪该物体
  - 当你移动手机或者物体时, 识别的对象和红框的位置是统一的
- 这里我们出的的对象是`VNDetectedObjectObservation`
- 定义一个观察属性

```
fileprivate var lastObservation: VNDetectedObjectObservation?
```
- 创建一个处理多个图像序列的请求

```
//处理与多个图像序列的请求handle
let sequenceHandle = VNSequenceRequestHandler()
```
- 创建跟踪识别请求

```objc
//4. 创建跟踪识别请求
let trackRequest = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: completionHandle)
//将精度设置为高
trackRequest.trackingLevel = .accurate

```

- 当用户点击屏幕时，我们想要找出用户点击的位置,
- 根据点击的位置, 获取到一个新的物体对象


```
//2. 转换坐标
let convertRect = visionTool.convertRect(viewRect: redView.frame, layerRect: previewLayer.frame)
        
//3. 根据点击的位置获取新的对象
let newObservation = VNDetectedObjectObservation(boundingBox: convertRect)
lastObservation = newObservation
```

- 获取到扫描的结果, 如果是一个`VNDetectedObjectObservation`对象, 重新赋值

```
//1. 获取一个实际的结果
guard let newObservation = observations?.first as? VNDetectedObjectObservation else { return }
            
//2. 重新赋值
self.lastObservation = newObservation
```

- 根据获取到的新值, 获取物体的坐标位置
- 转换坐标, 改变红色框的位置

```
//4. 坐标转换
let newRect = newObservation.boundingBox
let convertRect = visionTool.convertRect(newRect, self.previewLayer.frame)
self.redView.frame = convertRect
```

> 以上就是iOS 11的新框架Vision在Swift中的所有使用的情况
- 文中所列的内容可能有点空洞, 也稍微有点乱
- 小编也是刚接触Vision, 文中如有解释不全, 或者错误的地方, 还请不吝赐教


---

### GitHub--[Demo地址](https://github.com/coderQuanjun/JunVisionFace)

-  注意:  
  - 这里只是列出了主要的核心代码,具体的代码逻辑请参考demo
  - 文中相关介绍有的地方如果有不是很详细或者有更好建议的,欢迎联系小编
  - 如果方便的话, 还望star一下


---

### 其他相关文章
- [Swift之二维码的生成、识别和扫描](http://www.jianshu.com/p/0a30d1af8335)
- [iOS黑科技之(CoreImage)静态人脸识别(一)](http://www.jianshu.com/p/168007f6f8b4)
- [iOS黑科技之(AVFoundation)动态人脸识别(二)](http://www.jianshu.com/p/5e624dc68a64)
- [Swift之Vision 图像识别框架](http://www.jianshu.com/p/08174663d2e9)
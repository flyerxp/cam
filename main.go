package main

import (
	"fmt"
	"gocv.io/x/gocv"
)

// 色彩量化函数
func colorQuantization(src gocv.Mat, levels int) (gocv.Mat, error) {
	dst := gocv.NewMat()
	divisor := 256 / levels
	scalarMat := gocv.NewMatWithSize(src.Rows(), src.Cols(), src.Type())
	scalarMat.SetTo(gocv.NewScalar(float64(divisor), float64(divisor), float64(divisor), 0))

	if err := gocv.Divide(src, scalarMat, &dst); err != nil {
		scalarMat.Close()
		return gocv.NewMat(), fmt.Errorf("error in division during color quantization: %w", err)
	}
	if err := gocv.Multiply(dst, scalarMat, &dst); err != nil {
		scalarMat.Close()
		return gocv.NewMat(), fmt.Errorf("error in multiplication during color quantization: %w", err)
	}
	scalarMat.Close()
	return dst, nil
}

func main() {
	// 打开摄像头
	webcam, err := gocv.OpenVideoCapture(1)
	if err != nil {
		fmt.Printf("Error opening video capture device: %v\n", err)
		return
	}
	defer webcam.Close()

	// 创建窗口
	window := gocv.NewWindow("Anime Effect from Camera")
	defer window.Close()

	// 存储帧的矩阵
	frame := gocv.NewMat()
	defer frame.Close()

	for {
		if ok := webcam.Read(&frame); !ok {
			fmt.Printf("Device closed: %v\n", err)
			return
		}
		if frame.Empty() {
			continue
		}

		// 转换为灰度图像，仅用于边缘检测
		gray := gocv.NewMat()
		defer gray.Close()
		if err := gocv.CvtColor(frame, &gray, gocv.ColorBGRToGray); err != nil {
			fmt.Printf("Error converting to grayscale: %v\n", err)
			continue
		}

		// 双边滤波以平滑图像，适当降低平滑程度
		bilateralFiltered := gocv.NewMat()
		defer bilateralFiltered.Close()
		if err := gocv.BilateralFilter(frame, &bilateralFiltered, 10, 100, 100); err != nil {
			fmt.Printf("Error applying bilateral filter: %v\n", err)
			continue
		}

		// 色彩量化，提高级别以保留更多颜色细节
		quantized, err := colorQuantization(bilateralFiltered, 32)
		if err != nil {
			fmt.Printf("Error in color quantization: %v\n", err)
			continue
		}
		defer quantized.Close()

		// 边缘检测，降低阈值以保留更多边缘信息
		edges := gocv.NewMat()
		defer edges.Close()
		if err := gocv.Canny(gray, &edges, 80, 180); err != nil {
			fmt.Printf("Error applying Canny edge detection: %v\n", err)
			continue
		}

		// 将边缘转换为彩色图像
		edgesColor := gocv.NewMat()
		defer edgesColor.Close()
		if err := gocv.CvtColor(edges, &edgesColor, gocv.ColorGrayToBGR); err != nil {
			fmt.Printf("Error converting edges to color: %v\n", err)
			continue
		}

		// 创建一个副本用于最终结果
		animeFrame := quantized.Clone()
		defer animeFrame.Close()

		// 将边缘颜色置为黑色，然后合并到最终图像
		data, _ := edgesColor.DataPtrUint8()
		animeData, _ := animeFrame.DataPtrUint8()
		for y := 0; y < edgesColor.Rows(); y++ {
			for x := 0; x < edgesColor.Cols(); x++ {
				offset := (y*edgesColor.Cols() + x) * 3
				if data[offset] != 0 {
					animeData[offset] = 0
					animeData[offset+1] = 0
					animeData[offset+2] = 0
				}
			}
		}

		// 显示处理后的图像
		window.IMShow(animeFrame)
		if window.WaitKey(1) >= 0 {
			break
		}
	}
}

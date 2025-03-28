@echo off
REM git clone https://github.com/microsoft/vcpkg
REM cd vcpkg
REM  .\bootstrap-vcpkg.bat
REM copy vcpkg.exe C:\Windows\System32\vcpkg.exe
REM cd ..
REM pip install numpy scipy --upgrade
if not exist "C:\opencv" mkdir "C:\opencv"
if not exist "C:\opencv\build" mkdir "C:\opencv\build"

REM echo Downloading OpenCV sources
REM echo.
REM echo For monitoring the download progress please check the C:\opencv directory.
REM echo.

REM This is why there is no progress bar:
REM https://github.com/PowerShell/PowerShell/issues/2138

REM  echo Downloading: opencv-4.11.0.zip [91MB]
REM powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://github.com/opencv/opencv/archive/4.11.0.zip -OutFile c:\opencv\opencv-4.11.0.zip"
echo Extracting...
powershell -command "$ProgressPreference = 'SilentlyContinue'; Expand-Archive -Path c:\opencv\opencv-4.11.0.zip -DestinationPath c:\opencv"
REM del c:\opencv\opencv-4.11.0.zip /q
REM echo.

REM echo Downloading: opencv_contrib-4.11.0.zip [58MB]
REM powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://github.com/opencv/opencv_contrib/archive/4.11.0.zip -OutFile c:\opencv\opencv_contrib-4.11.0.zip"
echo Extracting...
powershell -ommand "$ProgressPreference = 'SilentlyContinue'; Expand-Archive -Path c:\opencv\opencv_contrib-4.11.0.zip -DestinationPath c:\opencv"
REM del c:\opencv\opencv_contrib-4.11.0.zip /q
REM echo.

REM echo Done with downloading and extracting sources.
REM echo.

@echo on

cd /D C:\opencv\build
set PATH=%PATH%;D:\Program Files\CMake\bin;C:\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin
if [%1]==[static] (
  echo Build static opencv
  set enable_shared=OFF
) else (
  set enable_shared=ON
)
cmake C:\opencv\opencv-4.11.0 -G "MinGW Makefiles" -BC:\opencv\build -DENABLE_CXX11=ON -DOPENCV_EXTRA_MODULES_PATH=C:\opencv\opencv_contrib-4.11.0\modules -DBUILD_SHARED_LIBS=%enable_shared% -DWITH_IPP=OFF -DWITH_MSMF=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=ON -DBUILD_opencv_java=OFF -DBUILD_opencv_python=OFF -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF -DBUILD_DOCS=OFF -DENABLE_PRECOMPILED_HEADERS=OFF -DBUILD_opencv_saliency=OFF -DBUILD_opencv_wechat_qrcode=ON -DCPU_DISPATCH= -DOPENCV_GENERATE_PKGCONFIG=ON -DWITH_OPENCL_D3D11_NV=OFF -DOPENCV_ALLOCATOR_STATS_COUNTER_TYPE=int64_t -Wno-dev
mingw32-make -j%NUMBER_OF_PROCESSORS%
mingw32-make install
rmdir c:\opencv\opencv-4.11.0 /s /q
rmdir c:\opencv\opencv_contrib-4.11.0 /s /q
chdir /D %GOPATH%\src\gocv.io\x\gocv

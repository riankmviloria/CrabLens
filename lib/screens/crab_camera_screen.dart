import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CrabCameraScreen extends StatefulWidget {
  const CrabCameraScreen({super.key});

  @override
  State<CrabCameraScreen> createState() => _CrabCameraScreenState();
}

class _CrabCameraScreenState extends State<CrabCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  int _cameraIndex = 0;

  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _showGuide = true;
  bool _flashEnabled = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  // ============================================================
  // INITIALIZE CAMERA
  // ============================================================

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('No camera found on this device.');
      }

      // Prefer the rear camera.
      final rearCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraIndex = rearCameraIndex >= 0 ? rearCameraIndex : 0;

      await _startCamera(_cameraIndex);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to initialize camera: $e';
        _isInitializing = false;
      });
    }
  }

  // ============================================================
  // START CAMERA
  // ============================================================

  Future<void> _startCamera(int index) async {
    final oldController = _controller;
    _controller = null;

    if (oldController != null) {
      await oldController.dispose();
    }

    if (!mounted) return;

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller = controller;

    await controller.initialize();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    try {
      await controller.setFlashMode(
        _flashEnabled ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {
      _flashEnabled = false;
    }

    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _errorMessage = null;
    });
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (controller == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller = null;
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      _initializeCamera();
    }
  }

  // ============================================================
  // FLASH
  // ============================================================

  Future<void> _toggleFlash() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final newValue = !_flashEnabled;

    try {
      await controller.setFlashMode(newValue ? FlashMode.torch : FlashMode.off);

      if (!mounted) return;

      setState(() {
        _flashEnabled = newValue;
      });
    } catch (e) {
      _showMessage('Flash is not available on this camera.');
    }
  }

  // ============================================================
  // SWITCH CAMERA
  // ============================================================

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isCapturing || _isInitializing) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    try {
      await _startCamera(_cameraIndex);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to switch camera: $e';
        _isInitializing = false;
      });
    }
  }

  // ============================================================
  // CAPTURE IMAGE
  // ============================================================

  Future<void> _captureImage() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await controller.takePicture();

      if (!mounted) return;

      Navigator.of(context).pop<XFile>(image);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCapturing = false;
      });

      _showMessage('Unable to capture image. Please try again.');
    }
  }

  // ============================================================
  // PICK FROM GALLERY
  // ============================================================

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 90,
      );

      if (!mounted || image == null) return;

      Navigator.of(context).pop<XFile>(image);
    } catch (e) {
      _showMessage('Unable to select image from gallery.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    final cameraReady = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ==================================================
            // CAMERA PREVIEW
            // ==================================================
            if (cameraReady)
              SizedBox.expand(
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.previewSize!.height,
                      height: controller.value.previewSize!.width,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              )
            else
              const ColoredBox(color: Colors.black),

            // ==================================================
            // TOP CONTROLS
            // ==================================================
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _roundButton(
                    icon: _flashEnabled ? Icons.flash_on : Icons.flash_off,
                    onTap: _toggleFlash,
                  ),
                ],
              ),
            ),

            // ==================================================
            // CAPTURE GUIDE
            // ==================================================
            if (_showGuide && cameraReady)
              Positioned(
                top: 75,
                left: 16,
                right: 16,
                child: _buildCaptureGuide(),
              ),

            // ==================================================
            // GUIDE TOGGLE
            // ==================================================
            if (_showGuide && cameraReady)
              Positioned(
                top: 285,
                right: 20,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showGuide = false;
                    });
                  },
                  child: const Text(
                    'Hide tips',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (cameraReady)
              Positioned(
                top: 75,
                right: 16,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showGuide = true;
                    });
                  },
                  icon: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Capture tips',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            // ==================================================
            // LOADING / ERROR
            // ==================================================
            if (_isInitializing || _errorMessage != null)
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isInitializing)
                        const CircularProgressIndicator(color: Colors.white)
                      else
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage ?? 'Preparing camera...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isInitializing = true;
                              _errorMessage = null;
                            });

                            _initializeCamera();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // ==================================================
            // BOTTOM CAMERA CONTROLS
            // ==================================================
            if (cameraReady)
              Positioned(
                left: 0,
                right: 0,
                bottom: 25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // GALLERY
                    _roundButton(
                      icon: Icons.photo_library_outlined,
                      onTap: _pickFromGallery,
                    ),

                    // CAPTURE BUTTON
                    GestureDetector(
                      onTap: _isCapturing ? null : _captureImage,
                      child: Container(
                        width: 78,
                        height: 78,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCapturing ? Colors.grey : Colors.white,
                          ),
                          child: _isCapturing
                              ? const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),

                    // SWITCH CAMERA
                    _roundButton(
                      icon: Icons.flip_camera_ios_outlined,
                      onTap: _switchCamera,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CAPTURE GUIDE UI
  // ============================================================

  Widget _buildCaptureGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Make sure the lighting is right '
                  'for better crab classification.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _guideItem(
            Icons.wb_sunny_outlined,
            'Use bright, natural light or a well-lit room.',
          ),
          const SizedBox(height: 12),

          _guideItem(
            Icons.visibility_off_outlined,
            'Avoid dark areas and heavy shadows.',
          ),
          const SizedBox(height: 12),

          _guideItem(
            Icons.center_focus_strong,
            'Keep the crab fully visible and in focus.',
          ),
          const SizedBox(height: 12),

          _guideItem(
            Icons.camera_alt_outlined,
            'Avoid blurry photos. Keep your phone steady.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GUIDE ITEM
  // ============================================================

  Widget _guideItem(IconData icon, String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ROUND BUTTON
  // ============================================================

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white, size: 25),
        ),
      ),
    );
  }
}

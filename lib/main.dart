import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const URCApp());
}

class URCApp extends StatelessWidget {
  const URCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'URC',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Home(),
      const TrendingPage(),
      const UploadPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() {
            tab = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Trending',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'URC',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Discover stories. Share your world.',
          style: TextStyle(
            color: Colors.white.withOpacity(.65),
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search videos...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'For You',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        for (final item in [
          ['A story worth sharing', Icons.auto_stories],
          ['Learn something new', Icons.school_outlined],
          ['Today around the world', Icons.public],
        ])
          Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 90,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7C4DFF),
                      Color(0xFF00BCD4),
                    ],
                  ),
                ),
                child: Icon(
                  item[1] as IconData,
                  size: 30,
                ),
              ),
              title: Text(
                item[0] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('URC • Video'),
              trailing: const Icon(Icons.play_circle_outline),
            ),
          ),
      ],
    );
  }
}

class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Trending',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover what people are watching.',
          style: TextStyle(
            color: Colors.white.withOpacity(.65),
          ),
        ),
        const SizedBox(height: 24),
        _trendingCard(
          context,
          'Top Gospel Stories',
          Icons.church_outlined,
        ),
        _trendingCard(
          context,
          'Education Today',
          Icons.school_outlined,
        ),
        _trendingCard(
          context,
          'World News',
          Icons.public,
        ),
      ],
    );
  }

  Widget _trendingCard(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('Trending on URC'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker picker = ImagePicker();

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String category = 'Entertainment';

  XFile? selectedVideo;
  VideoPlayerController? videoController;

  bool isInitializing = false;

  Future<void> pickVideo() async {
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video == null) {
      return;
    }

    await videoController?.dispose();

    setState(() {
      selectedVideo = video;
      videoController = null;
      isInitializing = true;
    });

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(video.path),
    );

    try {
      await controller.initialize();

      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        videoController = controller;
        isInitializing = false;
      });
    } catch (e) {
      await controller.dispose();

      if (!mounted) {
        return;
      }

      setState(() {
        isInitializing = false;
        selectedVideo = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not preview this video.',
          ),
        ),
      );
    }
  }

  Future<void> changeVideo() async {
    await pickVideo();
  }

  void publishVideo() {
    if (selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video first.'),
        ),
      );
      return;
    }

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a video title.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Video is ready. Cloud publishing comes next.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Upload Video',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Share your story with the URC community.',
          style: TextStyle(
            color: Colors.white.withOpacity(.65),
          ),
        ),
        const SizedBox(height: 24),

        if (selectedVideo == null)
          _buildChooseVideo()
        else
          _buildVideoPreview(),

        const SizedBox(height: 22),

        TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Video title',
            hintText: 'Give your video a title',
            prefixIcon: const Icon(Icons.title),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Tell viewers about your video...',
            alignLabelWithHint: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 55),
              child: Icon(Icons.description_outlined),
            ),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: category,
          decoration: InputDecoration(
            labelText: 'Category',
            prefixIcon: const Icon(Icons.category_outlined),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [
            'Gospel',
            'Education',
            'Entertainment',
            'News',
            'Sports',
            'Music',
            'Other',
          ]
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                category = value;
              });
            }
          },
        ),

        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: publishVideo,
          icon: const Icon(
            Icons.cloud_upload_outlined,
          ),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Publish Video',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChooseVideo() {
    return InkWell(
      onTap: pickVideo,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white24,
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF17122A),
              Color(0xFF10242A),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 56,
            ),
            SizedBox(height: 12),
            Text(
              'Choose a video',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Tap to select from your phone',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    final controller = videoController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 230,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: isInitializing
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : controller != null &&
                      controller.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: controller
                              .value
                              .aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            });
                          },
                          iconSize: 64,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.black54,
                          ),
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Video preview unavailable',
                      ),
                    ),
        ),

        const SizedBox(height: 10),

        if (controller != null &&
            controller.value.isInitialized)
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
          ),

        Row(
          children: [
            Expanded(
              child: Text(
                selectedVideo?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: 'Sound',
              onPressed: controller == null
                  ? null
                  : () {
                      setState(() {
                        controller.setVolume(
                          controller.value.volume > 0
                              ? 0
                              : 1,
                        );
                      });
                    },
              icon: Icon(
                controller != null &&
                        controller.value.volume > 0
                    ? Icons.volume_up
                    : Icons.volume_off,
              ),
            ),
            OutlinedButton.icon(
              onPressed: changeVideo,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Change'),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 42,
          child: Icon(
            Icons.person,
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'URC User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Your URC profile',
            style: TextStyle(
              color: Colors.white.withOpacity(.65),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Card(
          child: ListTile(
            leading: const Icon(Icons.video_library_outlined),
            title: const Text('My Videos'),
            subtitle: const Text('Your uploaded videos'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Liked Videos'),
            subtitle: const Text('Videos you liked'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('Manage your URC account'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

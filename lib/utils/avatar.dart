import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Avatar {
  final int id;
  final String imagePath;

  Avatar({required this.id, required this.imagePath});
}

List<Avatar> avatars = [
  Avatar(id: 1, imagePath: 'assets/if_adium_49043.png'),
  Avatar(id: 2, imagePath: 'assets/driver_1.png'),
  Avatar(id: 3, imagePath: 'assets/if_b02.png'),
  Avatar(id: 4, imagePath: 'assets/if_co1.png'),
  Avatar(id: 5, imagePath: 'assets/if_cattle_tuck_88245.png'),
  Avatar(id: 6, imagePath: 'assets/if_daf_girder_truck.png'),
  Avatar(id: 7, imagePath: 'assets/if_daf_tiper.png'),
  Avatar(id: 8, imagePath: 'assets/if_fa03.png'),
  Avatar(id: 9, imagePath: 'assets/if_fd.png'),
  Avatar(id: 10, imagePath: 'assets/if_fe05.png'),
  Avatar(id: 11, imagePath: 'assets/if_fi01.png'),
  Avatar(id: 12, imagePath: 'assets/if_fire_escape.png'),
  Avatar(id: 13, imagePath: 'assets/if_foden_concrete_tuck.png'),
  Avatar(id: 14, imagePath: 'assets/if_h05_.png'),
  Avatar(id: 15, imagePath: 'assets/if_jo1.png'),
  Avatar(id: 16, imagePath: 'assets/if_lorry_green.png'),
  Avatar(id: 17, imagePath: 'assets/if_tractor_unit_black_22998.png'),
  Avatar(id: 18, imagePath: 'assets/if_truck_yellow.png'),
  Avatar(id: 19, imagePath: 'assets/if_ambulance_45490.png'),
  Avatar(id: 20, imagePath: 'assets/if_bus_front_01_1988879.png'),
  Avatar(id: 21, imagePath: 'assets/if_bus_47405.png'),
  Avatar(id: 22, imagePath: 'assets/if_coraline_49044.png'),
  Avatar(id: 23, imagePath: 'assets/if_diagram_v2_32_37152.png'),
  Avatar(id: 24, imagePath: 'assets/if_evernote_49045.png'),
  Avatar(id: 25, imagePath: 'assets/if_firefox_49046.png'),
  Avatar(id: 26, imagePath: 'assets/if_freebsd_49049.png'),
  Avatar(id: 27, imagePath: 'assets/if_freebsd_daemon_386463.png'),
  Avatar(id: 28, imagePath: 'assets/if_guard_45502.png'),
  Avatar(id: 29, imagePath: 'assets/if_linux_tox_386476.png'),
  Avatar(id: 30, imagePath: 'assets/if_monkeys_audio_49052.png'),
  Avatar(id: 31, imagePath: 'assets/if_nike_37862.png'),
  Avatar(id: 32, imagePath: 'assets/if_policeman_45483.png'),
  Avatar(id: 33, imagePath: 'assets/if_receptionist_45441.png'),
  Avatar(id: 34, imagePath: 'assets/if_rocket_406798.png'),
  Avatar(id: 35, imagePath: 'assets/if_school_bus_44999.png'),
  Avatar(id: 36, imagePath: 'assets/if_transportation_service_45471.png'),
  Avatar(id: 37, imagePath: 'assets/if_truck_back_03_2140057.png'),
  Avatar(id: 38, imagePath: 'assets/if_truck_front_01_1988878.png'),
  Avatar(id: 39, imagePath: 'assets/if_truck_37865.png'),
  Avatar(id: 40, imagePath: 'assets/if_truck_44870.png'),
  Avatar(id: 41, imagePath: 'assets/if_truck_45435.png'),
  Avatar(id: 42, imagePath: 'assets/if_twitter_49054.png'),
  Avatar(id: 43, imagePath: 'assets/girls_female_woman_pers.png'),
  Avatar(id: 44, imagePath: 'assets/head_medical_man_avatar.png'),
  Avatar(id: 45, imagePath: 'assets/icons8.png'),
  Avatar(id: 46, imagePath: 'assets/icons8_semi_truck_50.png'),
  Avatar(id: 47, imagePath: 'assets/police_avatar_person.png'),
  Avatar(id: 48, imagePath: 'assets/police_wome.png'),
];

void showAvatarSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white, // Set the background color to white
        insetPadding: EdgeInsets.all(100.0),
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.8, // Set width to 80% of the screen width
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              Avatar avatar = avatars[index];
              return GestureDetector(
                onTap: () {
                  // Handle avatar selection

                  int selectedAvatarId = avatar.id;
                  print('Selected Avatar id $selectedAvatarId');
                  // Store the selected avatar ID in SharedPreferences
                  SharedPrefs.setInt('selectedAvatarId', selectedAvatarId);

                  // Call your backend API to update the avatar ID for the user
                  Navigator.pop(context); // Close the dialog
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    height: 64,
                    width: 64, // Customize the avatar width
                    child: Image.asset(
                      avatar.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

void _handleAvatarSelection(BuildContext context, int selectedAvatarId) async {
  print('Selected Avatar id $selectedAvatarId');
  await storeSelectedAvatarId(selectedAvatarId);
  Navigator.pop(context);
}

Future<void> storeSelectedAvatarId(int selectedAvatarId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('selectedAvatarId', selectedAvatarId);
}

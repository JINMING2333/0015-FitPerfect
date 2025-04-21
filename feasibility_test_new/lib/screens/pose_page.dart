import '../models/standard_pose_model.dart';

late List<StandardPose> standardModel;

@override
void initState() {
  super.initState();
  StandardPose.loadFromAssets('assets/standard_pose.json').then((value) {
    setState(() {
      standardModel = value;
    });
  });
}

#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Ungamed.Dismember;

namespace Ungamed.Dismember {
	[CustomEditor(typeof(DismemberManager))]
	public class DismemberManagerEditor : Editor {
		public override void OnInspectorGUI() {
			DrawDefaultInspector ();
			DismemberManager managerScript = (DismemberManager)target;
			if (GUILayout.Button ("Setup dismembering")) {
				managerScript.Setup ();
			}
			if (GUILayout.Button ("Create ragdoll only")) {
				managerScript.Setup (true);
			}
		}

	}
}
#endif
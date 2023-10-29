using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace AndreyGraphics {
public class AnimationController : MonoBehaviour {

public Animator anim;
	public ParticleSystem[] Particls;


public AudioSource audioSource;

	void Update () {
		if (Input.GetKeyDown(KeyCode.Mouse0)) {

	anim.SetBool("Shot", !anim.GetBool("Shot"));
}
	}

public	void ShotEnd () {
anim.SetBool("Shot",false);
	}
	void ParticleStart() {
		for (int i = 0;i < Particls.Length;i++){
Particls[i].Play();
		}
	}

void AudioStart() {
	audioSource.Play();
}

}
}
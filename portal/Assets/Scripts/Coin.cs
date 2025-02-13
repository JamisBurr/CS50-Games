using UnityEngine;
using System.Collections;

public class Coin : MonoBehaviour {

	// Use this for initialization
	void Start () {

	}

	// Update is called once per frame
	void Update () {

		// infinitely rotate this coin about the Y axis in world space
		transform.Rotate(0, 5f, 0, Space.World);
	}

	void OnTriggerEnter(Collider other) {

		// trigger coin pickup function if a helicopter collides with this
		other.GetComponent<PlayerController>().PickupCoin();
		Destroy(gameObject);
	}
}

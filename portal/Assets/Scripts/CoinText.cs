using UnityEngine;
using UnityEngine.UI;
using System.Collections;

[RequireComponent(typeof(Text))]
public class CoinText : MonoBehaviour {

	public GameObject player;
	private Text text;
	private int coins;

	// Use this for initialization
	void Start () {
		text = GetComponent<Text>();
	}

	// Update is called once per frame
	void Update () {
		if (player != null) {
			coins = player.GetComponent<PlayerController>().coinTotal;
		}
		text.text = "Coins: " + coins;
	}
}

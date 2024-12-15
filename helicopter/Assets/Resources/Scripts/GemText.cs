using UnityEngine;
using UnityEngine.UI;
using System.Collections;

[RequireComponent(typeof(Text))]
public class GemText : MonoBehaviour {

	public GameObject helicopter;
	private Text text;
	private int gems;

	// Use this for initialization
	void Start () {
		text = GetComponent<Text>();
	}

	// Update is called once per frame
	void Update () {
		if (helicopter != null) {
			gems = helicopter.GetComponent<HeliController>().gemTotal;
		}
		text.text = "Gems: " + gems;
	}
}
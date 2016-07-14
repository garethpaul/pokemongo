using UnityEngine;
using System.Collections;

public class HitObject : MonoBehaviour
{
	public GameObject item; //reference to the Score
	
	void OnCollisionEnter(Collision col)
	{
		Debug.Log("You collided");
		Destroy (item);

	}

	void OnTriggerEnter() //if ball hits collider
	{
		// int currentScore = int.Parse(score.GetComponent().text) + 1; //add 1 to the score
		// score.GetComponent().text = currentScore.ToString();
		Debug.Log("You triggered an event");
	}

}
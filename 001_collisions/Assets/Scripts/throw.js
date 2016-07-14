
 #pragma strict
  
 var power = 1000.0;
  
 private var startPos  : Vector3;
  
 function OnMouseDown() {
 	 Physics.gravity = new Vector3(0, -20, 0);
     startPos = Input.mousePosition;
     startPos.z = transform.position.z - Camera.main.transform.position.z;
     startPos = Camera.main.ScreenToWorldPoint(startPos);
 }
  
 function OnMouseUp() {
     var endPos = Input.mousePosition;
     endPos.z = transform.position.z - Camera.main.transform.position.z;
     endPos = Camera.main.ScreenToWorldPoint(endPos);
  
     var force = endPos - startPos;
     force.z = force.magnitude;
     force.Normalize();
  
     GetComponent.<Rigidbody>().AddForce(force * power);
     ReturnBall();
 }
  
 function ReturnBall() {
     yield WaitForSeconds(4.0);
     transform.position = Vector3.zero;
     GetComponent.<Rigidbody>().velocity = Vector3.zero;
 }

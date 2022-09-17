<?php
session_start();
header("content-type:text/html; charset=utf-8");

// include db connect class
// array for JSON response
require_once  $_SERVER['DOCUMENT_ROOT'] . '/Lib/config.php';
            
// include db connect class
require_once  $_SERVER['DOCUMENT_ROOT'] . '/Lib/db_connect.php';

// include db connect class
require_once  $_SERVER['DOCUMENT_ROOT'] . '/Lib/func.php';

$response = array();

// $receive_data = $_GET['uuid'];
// $date = new DateTime();
// $date_time = $date->format("y:m:d h:i:s");
// $myfile = fopen("datafile.txt", "a") or die("Unable to open file!");
// $txt =  $receive_data  . "\n";
// fwrite($myfile, $txt);
// fclose($myfile);

if(isset($_GET['uuid']) && !empty($_GET['uuid'])){

	$uuid = $_GET['uuid'] ;

	$response["success"] = true;
	$response["message"] = "성공적으로 공유 되었습니다.";

	$user = (isset($_GET['user']) && !empty($_GET['user']))? $_GET['user'] : "animal";

	$uuid_sql = "SELECT * from animal_token where uuid = '$uuid'";

	$uuid_result = mysqli_query($link,$uuid_sql);
	$ip = $_SERVER['REMOTE_ADDR'];

	$uuid_cnt = mysqli_num_rows($uuid_result);

	if ($uuid_cnt > 0){
		$response["success"] = true;
        $response["message"] = "성공적으로 공유 되었습니다.";
        $response["cnt"] = $uuid_cnt;
	}else{
		$response["success"] = false;
        $response["message"] = "아직 공유되지 않았습니다.";
        $response["cnt"] = $uuid_cnt;
	}

	echo json_encode($response, JSON_UNESCAPED_UNICODE);

}else{

	$response["success"] = false;
	$response["message"] = "GET DATA 에러입니다.";
	echo json_encode($response, JSON_UNESCAPED_UNICODE);

}

?>

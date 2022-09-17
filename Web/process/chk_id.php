<?php
session_start();
header("content-type:text/html; charset=utf-8");

// include db connect class
require_once $_SERVER["DOCUMENT_ROOT"] . "/Lib/config.php";

// include db connect class
require_once $_SERVER["DOCUMENT_ROOT"] . "/Lib/db_connect.php";

// include db connect class
require_once $_SERVER["DOCUMENT_ROOT"] . "/Lib/func.php";

// array for JSON response
$response = array();


if (
    !$_POST["id"]
) {
    $response["success"] = false;
    $response["message"] = "필드 입력 error.";
    $response["error"] = $_POST;
    echo json_encode($response);
    exit();
} else {

    $nickname = trim($_POST["id"]);

    $tmp_sql =
        "SELECT * from member where nickname = '$nickname'";

    $tmp_result = mysqli_query($link, $tmp_sql);
    $tmp_cnt = mysqli_num_rows($tmp_result);

    if ($tmp_cnt > 0) {
        $response["success"] = false;
        $response["message"] = "\"".$nickname."\" 이미 사용중인 아이디 입니다.";
        echo json_encode($response);
        exit();
    } else {
        $response["success"] = true;
        $response["message"] = "\"".$nickname."\" 사용 가능한 아이디 입니다.";
        echo json_encode($response);
        exit();
    }
}
?>
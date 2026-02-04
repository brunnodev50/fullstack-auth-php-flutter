<?php
require 'config_api.php';
$id = $_GET['id'] ?? 0;

$stmt = $pdo->prepare("SELECT id, nome, email, foto, acessos, status FROM usuarios WHERE id = ?");
$stmt->execute([$id]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    // Corrige caminho da foto para URL completa se necessário
    echo json_encode(["success" => true, "user" => $user]);
} else {
    echo json_encode(["success" => false, "message" => "Usuário não encontrado"]);
}
?>
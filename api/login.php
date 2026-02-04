<?php
require 'config_api.php';

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['email']) && isset($data['senha'])) {
    $email = $data['email'];
    $senha = $data['senha'];

    $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($senha, $user['senha'])) {
        if ($user['status'] !== 'ativo') {
            echo json_encode(["success" => false, "message" => "Conta " . $user['status']]);
        } else {
            // Conta Acesso
            $pdo->prepare("UPDATE usuarios SET acessos = acessos + 1 WHERE id = ?")->execute([$user['id']]);
            
            // Retorna dados para o App
            echo json_encode([
                "success" => true,
                "user" => [
                    "id" => $user['id'],
                    "nome" => $user['nome'],
                    "email" => $user['email'],
                    "foto" => $user['foto'],
                    "acessos" => $user['acessos'] + 1, // +1 visual
                    "status" => $user['status']
                ]
            ]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "E-mail ou senha inválidos"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Dados incompletos"]);
}
?>
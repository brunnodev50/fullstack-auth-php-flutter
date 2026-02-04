<?php
// api/register.php
require 'config_api.php';

// Recebe JSON do React Native
$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['nome']) && isset($data['email']) && isset($data['senha'])) {
    $nome = $data['nome'];
    $email = $data['email'];
    $senha = $data['senha'];

    // 1. Verifica se o e-mail já existe
    $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => false, "message" => "Este e-mail já está cadastrado."]);
    } else {
        try {
            // 2. Cria o hash da senha e insere
            $senhaHash = password_hash($senha, PASSWORD_DEFAULT);
            
            $insert = $pdo->prepare("INSERT INTO usuarios (nome, email, senha, acessos, status, foto) VALUES (?, ?, ?, 0, 'ativo', 'assets/default.png')");
            $insert->execute([$nome, $email, $senhaHash]);

            echo json_encode(["success" => true, "message" => "Conta criada com sucesso!"]);
        } catch (PDOException $e) {
            echo json_encode(["success" => false, "message" => "Erro no banco: " . $e->getMessage()]);
        }
    }
} else {
    echo json_encode(["success" => false, "message" => "Preencha todos os campos."]);
}
?>
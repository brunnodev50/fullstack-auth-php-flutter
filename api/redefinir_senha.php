<?php
// api/redefinir_senha.php
require 'config_api.php';
$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['email']) && isset($data['codigo']) && isset($data['senha'])) {
    $email = $data['email'];
    $codigo = $data['codigo'];
    $senha = $data['senha'];

    $stmt = $pdo->prepare("SELECT id, token_expira_em FROM usuarios WHERE email = ? AND token_reset = ?");
    $stmt->execute([$email, $codigo]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        if (date('Y-m-d H:i:s') > $user['token_expira_em']) {
            echo json_encode(["success" => false, "message" => "Código expirado."]);
        } else {
            $hash = password_hash($senha, PASSWORD_DEFAULT);
            $pdo->prepare("UPDATE usuarios SET senha = ?, token_reset = NULL, token_expira_em = NULL WHERE id = ?")->execute([$hash, $user['id']]);
            echo json_encode(["success" => true, "message" => "Senha alterada com sucesso!"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Código inválido."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Dados incompletos."]);
}
?>
<?php
require 'config_api.php';

// Como vem form-data, usamos $_POST e $_FILES, não json_decode
$id = $_POST['id'] ?? null;
$nome = $_POST['nome'] ?? null;
$email = $_POST['email'] ?? null;
$senha = $_POST['senha'] ?? null;

if (!$id) {
    echo json_encode(["success" => false, "message" => "ID não fornecido"]);
    exit;
}

try {
    $pdo->beginTransaction();

    // 1. Atualiza Foto
    if (isset($_FILES['foto']) && $_FILES['foto']['error'] === UPLOAD_ERR_OK) {
        $ext = strtolower(pathinfo($_FILES['foto']['name'], PATHINFO_EXTENSION));
        // Caminho relativo a partir da pasta api/
        // Vamos salvar na mesma estrutura do site: ../perfil/fotos/{ID}/
        $dir = "../perfil/fotos/" . $id . "/";
        
        if (!is_dir($dir)) mkdir($dir, 0777, true);

        $novo_nome = uniqid() . "." . $ext;
        $destino = $dir . $novo_nome;

        if (move_uploaded_file($_FILES['foto']['tmp_name'], $destino)) {
            // No banco salvamos o caminho relativo ao root do site: perfil/fotos...
            $caminho_banco = "perfil/fotos/" . $id . "/" . $novo_nome;
            $pdo->prepare("UPDATE usuarios SET foto = ? WHERE id = ?")->execute([$caminho_banco, $id]);
        }
    }

    // 2. Atualiza Dados
    if (!empty($senha)) {
        $hash = password_hash($senha, PASSWORD_DEFAULT);
        $pdo->prepare("UPDATE usuarios SET nome=?, email=?, senha=? WHERE id=?")->execute([$nome, $email, $hash, $id]);
    } else {
        $pdo->prepare("UPDATE usuarios SET nome=?, email=? WHERE id=?")->execute([$nome, $email, $id]);
    }

    $pdo->commit();
    echo json_encode(["success" => true, "message" => "Perfil atualizado!"]);

} catch (Exception $e) {
    $pdo->rollBack();
    echo json_encode(["success" => false, "message" => "Erro: " . $e->getMessage()]);
}
?>
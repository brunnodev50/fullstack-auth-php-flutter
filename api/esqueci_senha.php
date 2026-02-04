<?php
// api/esqueci_senha.php
require 'config_api.php';

// Carrega o PHPMailer
require 'PHPMailer/Exception.php';
require 'PHPMailer/PHPMailer.php';
require 'PHPMailer/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['email'])) {
    $email = $data['email'];
    
    // 1. Verifica Usuário
    $stmt = $pdo->prepare("SELECT id, nome FROM usuarios WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // 2. Gera Código
        $codigo = rand(100000, 999999);
        $expira = date('Y-m-d H:i:s', strtotime('+5 minutes'));
        
        $pdo->prepare("UPDATE usuarios SET token_reset = ?, token_expira_em = ? WHERE email = ?")->execute([$codigo, $expira, $email]);

        // 3. Envia E-mail (CONFIGURAÇÃO EXATA DA HOSTINGER)
        $mail = new PHPMailer(true);

        try {
            $mail->isSMTP();
            $mail->Host       = 'smtp.seu_host.com';     // Host da sua hospedagem
            $mail->SMTPAuth   = true;
            $mail->Username   = 'Seu e-mail';   // Seu e-mail
            $mail->Password   = '';     // Sua senha
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS; // SSL (Porta)
            $mail->Port       = 465;                      // Porta 
            $mail->CharSet    = 'UTF-8';

            // Configurações do E-mail
            $mail->setFrom('Digite seu e-mail', 'Digite seu texto');
            $mail->addAddress($email, $user['nome']);

            $mail->isHTML(true);
            $mail->Subject = 'Seu Código de Recuperação';
            $mail->Body    = "
                <div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>
                    <h2>Recuperação de Senha</h2>
                    <p>Olá, <strong>{$user['nome']}</strong>.</p>
                    <p>Use o código abaixo para redefinir sua senha no aplicativo:</p>
                    <div style='background: #f4f4f4; padding: 15px; font-size: 24px; font-weight: bold; text-align: center; letter-spacing: 5px; border-radius: 8px; border: 1px solid #ddd;'>
                        $codigo
                    </div>
                    <p style='color: #666; font-size: 12px; margin-top: 20px;'>Este código expira em 5 minutos.</p>
                </div>
            ";
            $mail->AltBody = "Seu código de recuperação é: $codigo";

            $mail->send();
            
            echo json_encode(["success" => true, "message" => "Código enviado para o seu e-mail!"]);

        } catch (Exception $e) {
            // Mostra o erro exato do PHPMailer para ajudar a debugar se falhar
            echo json_encode(["success" => false, "message" => "Erro no envio: " . $mail->ErrorInfo]);
        }
    } else {
        echo json_encode(["success" => true, "message" => "Se o e-mail existir, o código será enviado."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Informe o e-mail."]);
}
?>
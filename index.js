const mysql = require('mysql2/promise');

exports.handler = async (event) => {
    const config = {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        multipleStatements: true, 
        connectTimeout: 10000
    };

    let connection;

    try {
        console.log("Conectando ao RDS MySQL...");
        connection = await mysql.createConnection(config);

        const sqlScript = `
            CREATE TABLE IF NOT EXISTS usuario (
                id_usuario INT NOT NULL AUTO_INCREMENT,
                nome VARCHAR(80) NOT NULL,
                email VARCHAR(255) NOT NULL,
                username VARCHAR(30) NOT NULL,
                senha_hash VARCHAR(255) NOT NULL,
                bio VARCHAR(280) NULL,
                cargo VARCHAR(120) NULL,
                avatar_url VARCHAR(255) NULL,
                criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (id_usuario),
                UNIQUE KEY unique_email (email),
                UNIQUE KEY unique_username (username)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

            CREATE TABLE IF NOT EXISTS quiz (
                idQuiz INT NOT NULL AUTO_INCREMENT,
                nome VARCHAR(200) NOT NULL,
                PRIMARY KEY (idQuiz)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

            CREATE TABLE IF NOT EXISTS resposta (
                idResposta INT NOT NULL AUTO_INCREMENT,
                totalCerto INT NOT NULL DEFAULT 0,
                totalErrado INT NOT NULL DEFAULT 0,
                dataRegistro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                fkUsuario INT NOT NULL,
                fkQuiz INT NOT NULL,
                PRIMARY KEY (idResposta),
                KEY idx_fkUsuario (fkUsuario),
                KEY idx_fkQuiz (fkQuiz),
                CONSTRAINT fk_resposta_usuario FOREIGN KEY (fkUsuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE,
                CONSTRAINT fk_resposta_quiz FOREIGN KEY (fkQuiz) REFERENCES quiz (idQuiz) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

            CREATE TABLE IF NOT EXISTS publicacao (
                id_publicacao INT NOT NULL AUTO_INCREMENT,
                fk_usuario INT NOT NULL,
                texto VARCHAR(1200) NOT NULL,
                criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (id_publicacao),
                KEY idx_publicacao_criado (criado_em),
                CONSTRAINT fk_publicacao_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

            CREATE TABLE IF NOT EXISTS publicacao_reacao (
                fk_publicacao INT NOT NULL,
                fk_usuario INT NOT NULL,
                criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (fk_publicacao, fk_usuario),
                CONSTRAINT fk_reacao_publicacao FOREIGN KEY (fk_publicacao) REFERENCES publicacao (id_publicacao) ON DELETE CASCADE,
                CONSTRAINT fk_reacao_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

            CREATE TABLE IF NOT EXISTS publicacao_comentario (
                id_comentario INT NOT NULL AUTO_INCREMENT,
                fk_publicacao INT NOT NULL,
                fk_usuario INT NOT NULL,
                texto VARCHAR(600) NOT NULL,
                criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (id_comentario),
                KEY idx_comentario_publicacao (fk_publicacao, criado_em),
                CONSTRAINT fk_comentario_publicacao FOREIGN KEY (fk_publicacao) REFERENCES publicacao (id_publicacao) ON DELETE CASCADE,
                CONSTRAINT fk_comentario_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

            INSERT INTO quiz (idQuiz, nome) VALUES (1, 'Sistema Solar')
            ON DUPLICATE KEY UPDATE nome = VALUES(nome);

            INSERT INTO quiz (idQuiz, nome) VALUES (2, 'Viagens Espaciais')
            ON DUPLICATE KEY UPDATE nome = VALUES(nome);
        `;

        await connection.query(sqlScript);
        console.log("Banco 'bancocosmo' populado com sucesso!");

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Estrutura e dados do Cosmos Tech criados com sucesso!" }),
        };

    } catch (error) {
        console.error("Erro ao popular o banco Cosmos Tech:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message }),
        };
    } finally {
        if (connection) await connection.end();
    }
};
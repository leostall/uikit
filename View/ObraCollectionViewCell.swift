//
//  ObraCollectionViewCell.swift
//  galeria_artistas_cwb
//
//  Created by user293959 on 5/6/26.
//

import UIKit

class ObraCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets (conectados pelo Storyboard)
    @IBOutlet weak var imagemObraImageView: UIImageView!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var artistaLabel: UILabel!

    // MARK: - Configuração inicial
    override func awakeFromNib() {
        super.awakeFromNib()
        // Visual da célula
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground

        tituloLabel.font = UIFont.boldSystemFont(ofSize: 14)
        tituloLabel.numberOfLines = 1
        artistaLabel.font = UIFont.systemFont(ofSize: 12)
        artistaLabel.textColor = .secondaryLabel
        artistaLabel.numberOfLines = 1

        imagemObraImageView.contentMode = .scaleAspectFill
        imagemObraImageView.clipsToBounds = true
    }

    // MARK: - Método que recebe a obra e configura a célula
    func configurar(com obra: ObraDeArte) {
        // Tenta carregar a imagem do Assets; se não existir, usa um SF Symbol como placeholder
        if let imagem = UIImage(named: obra.imagemNome) {
            imagemObraImageView.image = imagem
            imagemObraImageView.contentMode = .scaleAspectFill
            imagemObraImageView.tintColor = nil
        } else {
            imagemObraImageView.image = UIImage(systemName: "photo.artframe")
            imagemObraImageView.contentMode = .scaleAspectFit
            imagemObraImageView.tintColor = .systemGray3
        }

        tituloLabel.text = obra.titulo
        artistaLabel.text = obra.artista
    }
}

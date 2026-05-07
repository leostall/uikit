import UIKit

class DetalheViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imagemImageView: UIImageView!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var artistaLabel: UILabel!
    @IBOutlet weak var anoLabel: UILabel!
    @IBOutlet weak var estiloLabel: UILabel!
    @IBOutlet weak var descricaoLabel: UILabel!

    // MARK: - Dado recebido da tela anterior
    var obra: ObraDeArte?

    // MARK: - Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarTela()
    }

    // MARK: - Configura a UI com os dados da obra
    private func configurarTela() {
        guard let obra = obra else { return }

        title = obra.titulo
        imagemImageView.image = UIImage(named: obra.imagemNome)
        imagemImageView.contentMode = .scaleAspectFit
        imagemImageView.clipsToBounds = true

        tituloLabel.text = obra.titulo
        artistaLabel.text = "por \(obra.artista)"
        anoLabel.text = "Ano: \(obra.ano)"
        estiloLabel.text = "Estilo: \(obra.estilo)"
        descricaoLabel.text = obra.descricao
    }

    // MARK: - Ação do botão compartilhar
    @IBAction func compartilharTapped(_ sender: UIBarButtonItem) {
        guard let obra = obra else { return }

        let texto = """
        Confira "\(obra.titulo)" de \(obra.artista)!
        Venha conhecer mais artistas curitibanos. 🎨
        """

        let activityVC = UIActivityViewController(
            activityItems: [texto],
            applicationActivities: nil
        )

        // Necessário pra iPad (senão crasha)
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = sender
        }

        present(activityVC, animated: true)
    }
}
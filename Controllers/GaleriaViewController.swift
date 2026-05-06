import UIKit

class GaleriaViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Dados
    private let obras: [ObraDeArte] = ObrasMock.todas

    // MARK: - Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Artistas Curitibanos"

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // Recalcula o layout quando a tela girar (responsividade)
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Navegação (passar a obra pra tela de detalhe)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mostrarDetalhe",
           let detalheVC = segue.destination as? DetalheViewController,
           let obra = sender as? ObraDeArte {
            detalheVC.obra = obra
        }
    }
}

// MARK: - DataSource
extension GaleriaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return obras.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ObraCell", for: indexPath
        ) as? ObraCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configurar(com: obras[indexPath.row])
        return cell
    }
}

// MARK: - Delegate (toque na célula)
extension GaleriaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let obra = obras[indexPath.row]
        performSegue(withIdentifier: "mostrarDetalhe", sender: obra)
    }
}

// MARK: - FlowLayout (tamanho responsivo das células)
extension GaleriaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Quantas colunas? 2 no iPhone retrato, 3 no paisagem ou iPad
        let larguraTela = collectionView.bounds.width
        let colunas: CGFloat = larguraTela > 600 ? 3 : 2
        let espacamento: CGFloat = 10
        let insetsLaterais: CGFloat = 20 // 10 esquerda + 10 direita

        let larguraDisponivel = larguraTela - insetsLaterais - (espacamento * (colunas - 1))
        let larguraCelula = larguraDisponivel / colunas
        let alturaCelula = larguraCelula * 1.3 // proporção ~3:4

        return CGSize(width: larguraCelula, height: alturaCelula)
    }
}

import UIKit

class GaleriaViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Dados
    private let obras: [ObraDeArte] = ObrasMock.todas
    private var obrasFiltradas: [ObraDeArte] = []   // resultado atual exibido na grade

    // MARK: - Pesquisa
    private let searchController = UISearchController(searchResultsController: nil)

    // Indica se a busca está ativa e tem texto digitado
    private var estaPesquisando: Bool {
        let texto = searchController.searchBar.text ?? ""
        return searchController.isActive && !texto.isEmpty
    }

    // MARK: - Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Artistas Curitibanos"

        obrasFiltradas = obras

        collectionView.dataSource = self
        collectionView.delegate = self

        configurarSearchController()
    }

    // Recalcula o layout quando a tela girar (responsividade)
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Configuração da Search Bar
    private func configurarSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar por obra ou artista"
        searchController.searchBar.autocapitalizationType = .none

        // Encaixa a barra de busca dentro da navigation bar (jeito moderno em iOS 11+)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // Importante pra search bar se comportar bem em navigation controller
        definesPresentationContext = true
    }

    // MARK: - Navegação (passa a obra pra tela de detalhe)
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
        return obrasFiltradas.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ObraCell", for: indexPath
        ) as? ObraCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configurar(com: obrasFiltradas[indexPath.row])
        return cell
    }
}

// MARK: - Delegate (interação com células + animações)
extension GaleriaViewController: UICollectionViewDelegate {

    // Quando o dedo encosta na célula: encolhe um pouco
    func collectionView(_ collectionView: UICollectionView,
                        didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       options: [.allowUserInteraction, .curveEaseOut]) {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            cell.alpha = 0.85
        }
    }

    // Quando o dedo solta sem confirmar: volta com efeito mola
    func collectionView(_ collectionView: UICollectionView,
                        didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.3,
                       options: [.allowUserInteraction]) {
            cell.transform = .identity
            cell.alpha = 1.0
        }
    }

    // Toque confirmado: faz um "pop" rápido e navega
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let obra = obrasFiltradas[indexPath.row]

        guard let cell = collectionView.cellForItem(at: indexPath) else {
            performSegue(withIdentifier: "mostrarDetalhe", sender: obra)
            return
        }

        // Animação rápida de "tap": encolhe -> volta -> navega
        UIView.animate(withDuration: 0.1,
                       animations: {
            cell.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15,
                           animations: {
                cell.transform = .identity
            }, completion: { _ in
                self.performSegue(withIdentifier: "mostrarDetalhe", sender: obra)
            })
        })
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

// MARK: - Pesquisa: filtra as obras conforme o usuário digita
extension GaleriaViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let texto = (searchController.searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if texto.isEmpty {
            // Sem texto: mostra tudo
            obrasFiltradas = obras
        } else {
            // Filtra por título OU artista (ambos case-insensitive)
            obrasFiltradas = obras.filter { obra in
                obra.titulo.lowercased().contains(texto) ||
                obra.artista.lowercased().contains(texto)
            }
        }

        collectionView.reloadData()
    }
}
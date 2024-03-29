defmodule DerpWeb.ProductController do
  use DerpWeb, :controller

  alias Derp.Catalogue
  alias Derp.Catalogue.Product

  def index(conn, _params) do
    products = Catalogue.list_products()
    render(conn, "index.html", products: products)
  end

  def new(conn, _params) do
    changeset = Catalogue.change_product(%Product{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    case Catalogue.create_product(product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: Routes.product_path(conn, :show, product))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)
    {storeId, localProductId} = Derp.Oracle.decode_product_id(id)
    product = %Derp.Catalogue.Product{
      id: id,
      store_id: storeId,
      local_id: localProductId
    }
    render(conn, "show.html", product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = Catalogue.get_product!(id)
    changeset = Catalogue.change_product(product)
    render(conn, "edit.html", product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Catalogue.get_product!(id)

    case Catalogue.update_product(product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: Routes.product_path(conn, :show, product))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", product: product, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Catalogue.get_product!(id)
    {:ok, _product} = Catalogue.delete_product(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: Routes.product_path(conn, :index))
  end
end

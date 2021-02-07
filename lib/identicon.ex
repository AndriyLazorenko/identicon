defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  The main method of Identicon module. Generates and saves identicon given
  string input.

  ## Examples

      iex> Identicon.main("Banana")
      iex> File.exists?("Banana.png")
      true

  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
  The function builds pixel map from grid.

  ## Examples

      iex> image = Identicon.hash_input("Banana")
      iex> image_with_grid = Identicon.build_grid(image)
      iex> %Identicon.Image{pixel_map: [map_entry_1 | _tail]} = Identicon.build_pixel_map(image_with_grid)
      iex> map_entry_1
      {{0, 0}, {50, 50}}

  """

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal+50, vertical+50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end
  @doc """
  The function filters odd squares off the grid atom in Identicon.Image.

  ## Examples

      iex> image = %Identicon.Image{grid: [{2,3}, {5,6}]}
      iex> %Identicon.Image{grid: [grid]} = Identicon.filter_odd_squares(image)
      iex> grid
      {2, 3}

  """


  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index})->
      rem(code,2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end


  @doc """
  Transforms input to list of integers, stores them under hex field of
  Identicon.Image struct.

  ## Examples

      iex> %Identicon.Image{hex: list} = Identicon.hash_input("Banana")
      iex> last = List.last(list)
      iex> last
      30


  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Builds a grid from list stored in hex atom of the image struct.
  Stores it back in grid atom of image struct.

  ## Examples:

      iex> image = Identicon.hash_input("Banana")
      iex> %Identicon.Image{grid: grid} = Identicon.build_grid(image)
      iex> last = List.last(grid)
      {24, 24}

  """

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  @doc """
  Picks color from first 3 ints of the array retrieved from image object.
  Stores them back in image under color name

  ## Examples

      iex> image = Identicon.hash_input("Banana")
      iex> img_with_color = Identicon.pick_color(image)
      iex> %Identicon.Image{color: color} = img_with_color
      iex> color
      {230, 249, 195}


  """

  def pick_color(%Identicon.Image{hex: [r,g,b | _tail]} = image) do
    %Identicon.Image{image | color: {r,g,b}}
  end

end

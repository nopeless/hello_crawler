defmodule HelloCrawler do

  @default_depth 3
  @default_headers []
  @default_options [follow_redirect: true]

  def get_links(url, opts \\ []) do
    url = URI.parse(url)

    context = %{
      depth: Keyword.get(opts, :depth, @default_depth),
      headers: Keyword.get(opts, :headers, @default_headers),
      options: Keyword.get(opts, :options, @default_options),
      host: url.host
    }

    url
    |> get_links([], context)
    |> Enum.map(&to_string/1)
    |> Enum.uniq
  end

  defp get_links(url, paths, context) do
    context = Map.put(context, :depth, context.depth - 1)
    
    if continue_crawl?(url, context) do
      IO.puts("Crawling \"#{url}\"...")
      paths = [to_string(url) | paths]

      targets = url
             |> to_string
             |> HTTPoison.get(context.headers, context.options)
             |> handle_response(url)
             |> Enum.reject(&Enum.member?(paths, to_string(&1)))

      paths = paths ++ (targets |> Enum.map(&to_string/1))

      [url | targets
             |> Enum.map(&(Task.async(fn -> get_links(&1, paths, context) end)))
             |> Enum.map(&Task.await(&1, :infinity))
             |> List.flatten]
    else
      [url]
    end
  end

  defp continue_crawl?(%{host: host}, %{depth: depth, host: initial}), do: depth >= 0 and host == initial

  defp handle_response({:ok, %{body: body }}, url) do
    with {:ok, document} <- Floki.parse_document(body) do
      document
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.map(&URI.merge(url, &1))
      |> Enum.uniq
    else
      _ -> 
        IO.puts("FAIL: \"#{url}\" (reason: invalid HTML)")
        []
    end
  end

  defp handle_response({_, %{ reason: reason }}, url) do
    IO.puts("FAIL: \"#{url}\" (reason: #{to_string(reason)})")
    []
  end
end

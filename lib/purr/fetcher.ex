defmodule Purr.Fetcher do
  require Logger

  @client Tentacat.Client.new(%{
            access_token: Application.get_env(:purr, :github)[:token],
            endpoint: Application.get_env(:purr, :github)[:url]
          })

  @repos Application.get_env(:purr, :repos)

  def get_all do
    Logger.info("Startring a fetch of all repositories #{inspect(@repos)}")

    all =
      @repos
      |> Enum.reduce([], fn repo_item, acc -> acc ++ List.wrap(get_pulls(repo_item)) end)

    GenServer.cast(Purr.MainServer, {:update_data, all})
  end

  def get_pulls(repo) do
    Logger.info("Getting #{inspect(repo)}")

    repo_struct = %{
      name: repo[:name],
      prs: []
    }

    prs =
      Tentacat.Pulls.filter(@client, repo[:owner], repo[:name], %{state: "open"})
      |> parse_pull(repo)
      |> Enum.reduce([], fn x, acc -> acc ++ List.wrap(parse_data(x, repo)) end)

    _repo_struct = %{repo_struct | prs: prs}
  end

  def parse_pull({200, [], _reponse}, repo) do
    Logger.info("No pull requests | #{inspect(repo)}")
    []
  end

  def parse_pull({200, data, _response}, repo) do
    Logger.info("Request cleanup | #{inspect(repo)}")
    data
  end

  def parse_data(data, repo) do
    Logger.info("Data parsing | #{inspect(repo)}")

    details = %{
      title: "",
      labels: [],
      user: %{},
      state: "",
      created_at: "",
      number: 0,
      comment_count: 0,
      file_count: 0,
      html_url: ""
    }

    details = %{details | labels: data["labels"]}
    details = %{details | title: data["title"]}
    details = %{details | user: data["user"]}
    details = %{details | state: data["state"]}
    details = %{details | created_at: data["created_at"]}
    details = %{details | number: data["number"]}
    details = %{details | html_url: data["html_url"]}
    details = %{details | comment_count: get_comment_count(repo, data["number"])}
    details = Map.merge(details, get_file_count(repo, data["number"]))
  end

  def get_comment_count(repo, pr_number) do
    Logger.info("Grabbing comments for #{inspect(repo)} and PR #{inspect(pr_number)}")

    {_, body, _response} =
      Tentacat.Pulls.Comments.list(@client, repo[:owner], repo[:name], pr_number)

    length(body)
  end

  def get_file_count(repo, pr_number) do
    Logger.info("Grabbing file stats for #{inspect(repo)} and PR #{inspect(pr_number)}")

    {_, body, _response} =
      Tentacat.Pulls.Files.list(@client, repo[:owner], repo[:name], pr_number)

    file_count = length(body)
    change_additions = Enum.reduce(body, 0, fn x, acc -> x["additions"] + acc end)
    change_deletions = Enum.reduce(body, 0, fn x, acc -> x["deletions"] + acc end)

    %{
      :file_count => file_count,
      :change_additions => change_additions,
      :change_deletions => change_deletions
    }
  end

  def add_lists(enumerator, list) do
    enumerator
    |> Enum.reduce([0], fn _, acc ->
      [acc | list]
    end)
    |> List.flatten()
  end
end

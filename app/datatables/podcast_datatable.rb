class PodcastDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :edit_podcast_path, :podcast_path, :l

  def sortable_columns
    @sortable_columns ||= [
      'Podcast.id',
      'Podcast.title',
      'Podcast.category',
      'Podcast.itunes_url',
      'Podcast.feed_url',
      'Podcast.updated_at',
      'Podcast.created_at',
      'Podcast.failed',
      'Podcast.done'
    ]
  end

  def searchable_columns
    @searchable_columns ||= [
      'Podcast.id',
      'Podcast.title',
      'Podcast.category',
      'Podcast.itunes_url',
      'Podcast.feed_url'
    ]
  end

  def self.columns
    'columns: [' +
      '{sortable: true, searchable: true},' * 5 +
      '{sortable: true, searchable: false},' * 4 +
      '{sortable: false, searchable: false},' * 3 +
    ']'
  end

  private

  def data
    records.map do |record|
      [
        record.id,
        record.title,
        record.category,
        record.itunes_url,
        record.feed_url,
        l(record.updated_at, format: :long),
        l(record.created_at, format: :long),
        record.failed,
        record.done,
        link_to('show', podcast_path(record)),
        link_to('edit', edit_podcast_path(record)),
        link_to('delete', podcast_path(record),
                          method: :delete,
                          data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def get_raw_records
    Podcast.all()
  end
end